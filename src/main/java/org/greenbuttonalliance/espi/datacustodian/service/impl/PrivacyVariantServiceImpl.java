package org.greenbuttonalliance.espi.datacustodian.service.impl;

import org.greenbuttonalliance.espi.common.domain.IdentifiedObject;
import org.greenbuttonalliance.espi.common.domain.UsagePoint;
import org.greenbuttonalliance.espi.common.domain.UsageSummary;
import org.greenbuttonalliance.espi.common.domain.MeterReading;
import org.greenbuttonalliance.espi.common.domain.IntervalBlock;
import org.greenbuttonalliance.espi.common.models.atom.LinkType;
import org.greenbuttonalliance.espi.common.service.ResourceService;
import org.greenbuttonalliance.espi.datacustodian.service.PrivacyVariantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import javax.sql.DataSource;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
public class PrivacyVariantServiceImpl implements PrivacyVariantService {

    private final Log logger = LogFactory.getLog(getClass());

    @Autowired
    private DataSource dataSource;

    @Autowired
    private ResourceService resourceService;

    private static final List<String> LEVELS = Arrays.asList("full", "medium", "low", "high");

    @Override
    @Transactional
    public void createPrivacyVariants() {
        // 1) Preferred: run classpath SQL to generate placeholder variants (idempotent)
        boolean createdBySql = false;
        try {
            ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
            populator.addScript(new ClassPathResource("/etc/migrations/20250911_privacy_placeholders.sql"));
            populator.addScript(new ClassPathResource("/etc/migrations/20250911_privacy_placeholders_cleanup.sql"));
            populator.addScript(new ClassPathResource("/etc/migrations/20250911_privacy_placeholders_fixlinks.sql"));
            populator.setContinueOnError(true);
            populator.execute(dataSource);
            createdBySql = hasAnyPrivacyVariants();
        } catch (Exception e) {
            // fall back to programmatic cloning
        }

        if (createdBySql) {
            return;
        }

        // 2) Fallback: programmatically clone UsagePoints (and summaries) per privacy level
        // NOTE: This code intentionally creates variants with brand-new UUIDs to keep them valid in the JPA layer.
        // Comment out this fallback when a real Privacy API is available and wired in.
        programmaticCloneVariants();

        /*
         * Placeholder: when a dedicated Privacy API is available, prefer something like:
         *
         * // Commented example (no-op):
         * // privacyApi.generateVariantsForAllUsagePoints(Arrays.asList("full","medium","low","high"));
         * // or per retail customer:
         * // privacyApi.generateVariantsForRetailCustomer(retailCustomerId, Arrays.asList("full","medium","low","high"));
         */
    }

    private boolean hasAnyPrivacyVariants() {
        try {
            List<Long> ids = resourceService.findAllIds(UsagePoint.class);
            for (Long id : ids) {
                UsagePoint up = resourceService.findById(id, UsagePoint.class);
                if (up == null) continue;
                for (LinkType link : up.getRelatedLinks()) {
                    if (link != null && link.getRel() != null && link.getRel().startsWith("privacy:")) {
                        return true;
                    }
                }
            }
        } catch (Exception ignore) {
            // no-op, assume none
        }
        return false;
    }

    @Transactional
    protected void programmaticCloneVariants() {
        List<Long> ids = resourceService.findAllIds(UsagePoint.class);
        for (Long id : ids) {
            UsagePoint canonical = resourceService.findById(id, UsagePoint.class);
            if (canonical == null) continue;

            // Skip if this UsagePoint is already a privacy variant (ends with -level)
            // Handle the case where getUUID() might fail due to malformed UUID strings
            String uuidStr = "";
            try {
                UUID uuid = canonical.getUUID();
                uuidStr = uuid != null ? uuid.toString() : "";
            } catch (Exception e) {
                // If getUUID() fails, try to get the raw string from the field
                // This can happen when SQL scripts create malformed UUID strings
                logger.warn("Failed to parse UUID for UsagePoint " + id + ": " + e.getMessage());
                // Skip this UsagePoint as it's likely malformed
                continue;
            }
            
            if (uuidStr.matches(".*-(full|medium|low|high)$")) continue;

            // Skip if this UsagePoint already has privacy variants
            boolean hasPrivacy = canonical.getRelatedLinks().stream()
                    .anyMatch(l -> l.getRel() != null && l.getRel().startsWith("privacy:"));
            if (hasPrivacy) {
                System.out.println("PrivacyVariantServiceImpl: Canonical UsagePoint already has privacy variants, updating them with meter readings");
                // Instead of skipping, update existing variants with meter readings
                updateExistingVariantsWithMeterReadings(canonical);
                continue;
            }

            // Retry logic for lock waits
            int retries = 3;
            boolean success = false;
            while (retries > 0 && !success) {
                try {
                    cloneVariantsForUsagePoint(canonical);
                    success = true;
                } catch (org.springframework.dao.PessimisticLockingFailureException e) {
                    retries--;
                    if (retries > 0) {
                        try {
                            Thread.sleep(1000); // Wait 1s before retry
                        } catch (InterruptedException ie) {
                            Thread.currentThread().interrupt();
                        }
                    } else {
                        throw e; // Re-throw after retries
                    }
                }
            }
        }
    }

    @Transactional
    private void updateExistingVariantsWithMeterReadings(UsagePoint canonical) {
        System.out.println("PrivacyVariantServiceImpl: Updating existing variants with meter readings");
        
        // Get all privacy variant links from the canonical UsagePoint
        List<LinkType> privacyLinks = canonical.getRelatedLinks().stream()
                .filter(l -> l.getRel() != null && l.getRel().startsWith("privacy:"))
                .collect(java.util.stream.Collectors.toList());
        
        System.out.println("PrivacyVariantServiceImpl: Found " + privacyLinks.size() + " privacy variant links");
        
        for (LinkType link : privacyLinks) {
            try {
                String variantHref = link.getHref();
                if (variantHref != null && variantHref.contains("/UsagePoint/")) {
                    String uuidStr = variantHref.substring(variantHref.lastIndexOf("/") + 1);
                    System.out.println("PrivacyVariantServiceImpl: Processing variant UUID: " + uuidStr);
                    
                    // Extract base UUID if it has a privacy suffix
                    String baseUuidStr = uuidStr;
                    if (uuidStr.matches(".*-(full|medium|low|high)$")) {
                        baseUuidStr = uuidStr.substring(0, uuidStr.lastIndexOf("-"));
                        System.out.println("PrivacyVariantServiceImpl: Extracted base UUID: " + baseUuidStr);
                    }
                    
                    // Find the variant UsagePoint by its actual UUID field
                    UsagePoint variant = null;
                    try {
                        // First try to find by the href UUID string (which might be extended)
                        variant = resourceService.findByUUIDString(uuidStr);
                        if (variant == null && !baseUuidStr.equals(uuidStr)) {
                            // If not found, try with the base UUID
                            variant = resourceService.findByUUIDString(baseUuidStr);
                        }
                    } catch (Exception e) {
                        System.out.println("PrivacyVariantServiceImpl: Exception finding variant by UUID: " + e.getMessage());
                        // Try to find by iterating through usage points with matching href
                        List<Long> usagePointIds = resourceService.findAllIds(UsagePoint.class);
                        for (Long upId : usagePointIds) {
                            UsagePoint up = resourceService.findById(upId, UsagePoint.class);
                            if (up.getSelfLink() != null && uuidStr.equals(up.getSelfLink().getHref().substring(up.getSelfLink().getHref().lastIndexOf("/") + 1))) {
                                variant = up;
                                break;
                            }
                        }
                    }
                    if (variant != null) {
                        System.out.println("PrivacyVariantServiceImpl: Found variant UsagePoint: " + variant.getId());
                        
                        // Check if variant already has meter readings
                        if (variant.getMeterReadings() == null || variant.getMeterReadings().isEmpty()) {
                            System.out.println("PrivacyVariantServiceImpl: Variant has no meter readings, copying from canonical");
                            
                            // Copy meter readings from canonical to variant
                            if (canonical.getMeterReadings() != null) {
                                System.out.println("PrivacyVariantServiceImpl: Canonical has " + canonical.getMeterReadings().size() + " meter readings");
                                for (MeterReading src : canonical.getMeterReadings()) {
                                    System.out.println("PrivacyVariantServiceImpl: Copying meter reading: " + src.getId());
                                    MeterReading dst = new MeterReading();
                                    copyMeterReading(src, dst);
                                    dst.setUsagePoint(variant);
                                    variant.addMeterReading(dst);
                                    // Don't merge individual meter readings - let cascade handle it

                                    // Copy associated IntervalBlocks using the new ResourceService method
                                    MeterReading srcWithBlocks = resourceService.findMeterReadingWithIntervalBlocks(src.getId());
                                    if (srcWithBlocks != null && srcWithBlocks.getIntervalBlocks() != null && !srcWithBlocks.getIntervalBlocks().isEmpty()) {
                                        System.out.println("PrivacyVariantServiceImpl: Meter reading has " + srcWithBlocks.getIntervalBlocks().size() + " interval blocks");
                                        for (IntervalBlock srcBlock : srcWithBlocks.getIntervalBlocks()) {
                                            IntervalBlock dstBlock = new IntervalBlock();
                                            copyIntervalBlock(srcBlock, dstBlock);
                                            dstBlock.setMeterReading(dst);
                                            dst.addIntervalBlock(dstBlock);
                                            // Don't merge individual interval blocks - let cascade handle it
                                            System.out.println("PrivacyVariantServiceImpl: Successfully copied interval block");
                                        }
                                    } else {
                                        System.out.println("PrivacyVariantServiceImpl: Meter reading has no interval blocks or could not load them");
                                    }
                                }
                                resourceService.merge(variant);
                                System.out.println("PrivacyVariantServiceImpl: Successfully updated variant with meter readings");
                            } else {
                                System.out.println("PrivacyVariantServiceImpl: Canonical has no meter readings to copy");
                            }
                        } else {
                            System.out.println("PrivacyVariantServiceImpl: Variant already has meter readings");
                        }
                    } else {
                        System.out.println("PrivacyVariantServiceImpl: Could not find variant UsagePoint");
                    }
                }
            } catch (Exception e) {
                System.out.println("PrivacyVariantServiceImpl: Exception updating variant: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    @Transactional
    private void cloneVariantsForUsagePoint(UsagePoint canonical) {
        String canonicalHref = safeSelfHref(canonical);

        for (String level : LEVELS) {
            System.out.println("PrivacyVariantServiceImpl: Creating variant for level: " + level);
            UsagePoint variant = new UsagePoint();

            // Copy simple fields
            variant.setDescription(appendPrivacyTag(canonical.getDescription(), level));
            variant.setServiceCategory(canonical.getServiceCategory());
            variant.setRoleFlags(canonical.getRoleFlags());
            variant.setStatus(canonical.getStatus());
            variant.setRetailCustomer(canonical.getRetailCustomer());
            variant.setLocalTimeParameters(canonical.getLocalTimeParameters());

            // Fresh UUIDs to keep JPA happy; set links
            UUID newUUID = UUID.randomUUID();
            variant.setUUID(newUUID);
            // ensure link objects exist
            if (variant.getSelfLink() == null) {
                variant.setSelfLink(new LinkType());
                variant.getSelfLink().setRel(LinkType.SELF);
            }
            variant.getSelfLink().setHref("/espi/1_1/resource/UsagePoint/" + newUUID);
            if (canonical.getUpLink() != null) {
                if (variant.getUpLink() == null) {
                    variant.setUpLink(new LinkType());
                }
                variant.getUpLink().setRel(LinkType.UP);
                variant.getUpLink().setHref(canonical.getUpLink().getHref());
            }

            // Link variant -> canonical
            LinkType toCanonical = new LinkType();
            toCanonical.setRel("canonical");
            toCanonical.setHref(canonicalHref);
            variant.getRelatedLinks().add(toCanonical);

            // Persist/merge variant first in its own transaction context
            variant = resourceService.merge(variant);

            // Link canonical -> variant (privacy:<level>)
            String variantHref = safeSelfHref(variant);
            LinkType privacyLink = new LinkType();
            privacyLink.setRel("privacy:" + level);
            privacyLink.setHref(variantHref);
            canonical.getRelatedLinks().add(privacyLink);

            // Clone UsageSummaries minimally (same values, new UUIDs) so variants have data
            if (canonical.getUsageSummaries() != null) {
                for (UsageSummary src : canonical.getUsageSummaries()) {
                    UsageSummary dst = new UsageSummary();
                    copyUsageSummary(src, dst);
                    dst.setUsagePoint(variant);
                    variant.addUsageSummary(dst);
                    // Don't merge individual summaries - let cascade handle it
                }
            }

            // Clone MeterReadings and their IntervalBlocks for privacy variants
            if (canonical.getMeterReadings() != null) {
                System.out.println("PrivacyVariantServiceImpl: Canonical UsagePoint has " + canonical.getMeterReadings().size() + " meter readings");
                for (MeterReading src : canonical.getMeterReadings()) {
                    System.out.println("PrivacyVariantServiceImpl: Copying meter reading: " + src.getId());
                    try {
                        MeterReading dst = new MeterReading();
                        copyMeterReading(src, dst);
                        dst.setUsagePoint(variant);
                        variant.addMeterReading(dst);
                        // Don't merge individual meter readings - let cascade handle it
                        System.out.println("PrivacyVariantServiceImpl: Successfully copied meter reading to variant");

                                                                        // Clone associated IntervalBlocks using the new ResourceService method
                        MeterReading srcWithBlocks = resourceService.findMeterReadingWithIntervalBlocks(src.getId());
                        if (srcWithBlocks != null && srcWithBlocks.getIntervalBlocks() != null) {
                            System.out.println("PrivacyVariantServiceImpl: Meter reading has " + srcWithBlocks.getIntervalBlocks().size() + " interval blocks");
                            for (IntervalBlock srcBlock : srcWithBlocks.getIntervalBlocks()) {
                                IntervalBlock dstBlock = new IntervalBlock();
                                copyIntervalBlock(srcBlock, dstBlock);
                                dstBlock.setMeterReading(dst);
                                dst.addIntervalBlock(dstBlock);
                                // Don't merge individual interval blocks - let cascade handle it
                                System.out.println("PrivacyVariantServiceImpl: Successfully copied interval block");
                            }
                        } else {
                            System.out.println("PrivacyVariantServiceImpl: Meter reading has no interval blocks or could not load them");
                        }
                    } catch (Exception e) {
                        System.out.println("PrivacyVariantServiceImpl: Exception copying meter reading: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            } else {
                System.out.println("PrivacyVariantServiceImpl: Canonical UsagePoint has no meter readings");
            }
        }
        resourceService.merge(canonical);
    }

    private static String appendPrivacyTag(String description, String level) {
        String base = description == null ? "" : description.trim();
        if (base.isEmpty()) return "[privacy=" + level + "]";
        return base + " [privacy=" + level + "]";
    }

    private static void copyUsageSummary(UsageSummary src, UsageSummary dst) {
        // Copy fields; set a new valid UUID
        dst.setUUID(UUID.randomUUID());
        dst.setDescription(src.getDescription());
        dst.setBillingPeriod(src.getBillingPeriod());
        dst.setBillLastPeriod(src.getBillLastPeriod());
        dst.setBillToDate(src.getBillToDate());
        dst.setCostAdditionalLastPeriod(src.getCostAdditionalLastPeriod());
        dst.setCurrency(src.getCurrency());
        dst.setOverallConsumptionLastPeriod(src.getOverallConsumptionLastPeriod());
        dst.setQualityOfReading(src.getQualityOfReading());
        dst.setStatusTimeStamp(src.getStatusTimeStamp());
        dst.setRatchetDemandPeriod(src.getRatchetDemandPeriod());
        dst.setCurrentBillingPeriodOverAllConsumption(src.getCurrentBillingPeriodOverAllConsumption());
        dst.setCurrentDayLastYearNetConsumption(src.getCurrentDayLastYearNetConsumption());
        dst.setCurrentDayNetConsumption(src.getCurrentDayNetConsumption());
        dst.setCurrentDayOverallConsumption(src.getCurrentDayOverallConsumption());
        dst.setPeakDemand(src.getPeakDemand());
        dst.setPreviousDayLastYearOverallConsumption(src.getPreviousDayLastYearOverallConsumption());
        dst.setPreviousDayNetConsumption(src.getPreviousDayNetConsumption());
        dst.setPreviousDayOverallConsumption(src.getPreviousDayOverallConsumption());
        dst.setRatchetDemand(src.getRatchetDemand());
    }

    private static void copyMeterReading(MeterReading src, MeterReading dst) {
        // Copy fields; set a new valid UUID
        dst.setUUID(UUID.randomUUID());
        dst.setDescription(src.getDescription());
        dst.setPublished(src.getPublished());
        dst.setUpdated(src.getUpdated());
        dst.setReadingType(src.getReadingType());
        // Links will be set by JPA or manually if needed
    }

    private static void copyIntervalBlock(IntervalBlock src, IntervalBlock dst) {
        // Copy fields; set a new valid UUID
        dst.setUUID(UUID.randomUUID());
        dst.setDescription(src.getDescription());
        dst.setPublished(src.getPublished());
        dst.setUpdated(src.getUpdated());
        dst.setInterval(src.getInterval());
        // IntervalReadings need to be copied individually and persisted
        if (src.getIntervalReadings() != null) {
            dst.setIntervalReadings(new java.util.ArrayList<>());
            for (org.greenbuttonalliance.espi.common.domain.IntervalReading srcReading : src.getIntervalReadings()) {
                org.greenbuttonalliance.espi.common.domain.IntervalReading dstReading = 
                    new org.greenbuttonalliance.espi.common.domain.IntervalReading();
                // Copy the reading data
                dstReading.setCost(srcReading.getCost());
                dstReading.setValue(srcReading.getValue());
                dstReading.setTimePeriod(srcReading.getTimePeriod());
                // Set the relationship
                dstReading.setIntervalBlock(dst);
                dst.getIntervalReadings().add(dstReading);
            }
        }
    }

    private static String safeSelfHref(IdentifiedObject io) {
        if (io.getSelfLink() != null && io.getSelfLink().getHref() != null) {
            return io.getSelfLink().getHref();
        }
        if (io.getUUID() != null) {
            return "/espi/1_1/resource/UsagePoint/" + io.getUUID();
        }
        return null;
    }
}

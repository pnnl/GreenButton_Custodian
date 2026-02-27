package org.greenbuttonalliance.espi.datacustodian.web.api;

import org.greenbuttonalliance.espi.common.domain.RetailCustomer;
import org.greenbuttonalliance.espi.common.service.ImportService;
import org.greenbuttonalliance.espi.common.service.RetailCustomerService;
import org.greenbuttonalliance.espi.datacustodian.service.PrivacyVariantService;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.servlet.http.HttpServletResponse;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Propagation;
import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api/data")
public class DataImportRESTController {

    private final Log logger = LogFactory.getLog(getClass());

    @Autowired
    private ImportService importService;

    @Autowired
    private RetailCustomerService retailCustomerService;

    @Autowired(required = false)
    private PrivacyVariantService privacyVariantService;

    @PersistenceContext
    private EntityManager entityManager;

    /**
     * Import a Green Button XML payload for a given Retail Customer with privacy level support.
     * POST /api/data/import?retailCustomerId=1&privacyLevel=high
     * privacyLevel can be: original, full, high, medium, low (for tagged differential privacy files)
     */
    @PostMapping(value = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Transactional
    public void importUsagePointData(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "privacyLevel", required = false) String privacyLevel,
            @RequestParam(value = "retailCustomerId", defaultValue = "1") Long retailCustomerId,
            HttpServletResponse response) throws IOException {
        
        logger.info("Starting import for retailCustomerId=" + retailCustomerId + 
                (privacyLevel != null ? ", privacyLevel=" + privacyLevel : ""));
        
        try {
            if (privacyLevel != null && !privacyLevel.isEmpty()) {
                // Handle tagged privacy variant XML
                importTaggedPrivacyVariant(file, retailCustomerId, privacyLevel, response);
            } else {
                // Handle canonical data (no privacy tags)
                try (InputStream inputStream = file.getInputStream()) {
                    importService.importData(inputStream, retailCustomerId);
                    logger.info("Import completed successfully for canonical data");
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Import completed successfully");
                }
            }
        } catch (Exception e) {
            logger.error("Import failed: " + e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Import failed: " + e.getMessage());
        }
    }
    
    private void importTaggedPrivacyVariant(MultipartFile file, Long retailCustomerId, 
                                           String privacyLevel, HttpServletResponse response) throws Exception {
        
        long startTime = System.currentTimeMillis();
        logger.info("Processing tagged privacy variant: " + privacyLevel);
        
        // Step 1: Read original XML content
        long step1Start = System.currentTimeMillis();
        String originalXml;
        try (InputStream inputStream = file.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
            StringBuilder xmlBuilder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                xmlBuilder.append(line).append("\n");
            }
            originalXml = xmlBuilder.toString();
        }
        long step1End = System.currentTimeMillis();
        logger.info("TIMING: Step 1 (Read XML) took " + (step1End - step1Start) + "ms, XML size: " + originalXml.length() + " chars");
        
        // Step 2: Preprocess XML - replace tagged UUIDs with temporary valid UUIDs
        long step2Start = System.currentTimeMillis();
        Map<String, String> uuidMappings = new HashMap<>();
        String processedXml = preprocessTaggedUUIDs(originalXml, privacyLevel, uuidMappings);
        long step2End = System.currentTimeMillis();
        logger.info("TIMING: Step 2 (Preprocess UUIDs) took " + (step2End - step2Start) + "ms, mappings: " + uuidMappings.size());
        
        // Step 3: Import using processed XML
        long step3Start = System.currentTimeMillis();
        try (InputStream processedStream = new ByteArrayInputStream(processedXml.getBytes())) {
            importService.importData(processedStream, retailCustomerId);
        }
        long step3End = System.currentTimeMillis();
        logger.info("TIMING: Step 3 (Import data) took " + (step3End - step3Start) + "ms");
        
        // Step 4: Post-process - restore tagged UUIDs in database
        long step4Start = System.currentTimeMillis();
        restoreTaggedUUIDs(uuidMappings, privacyLevel);
        long step4End = System.currentTimeMillis();
        logger.info("TIMING: Step 4 (Restore UUIDs) took " + (step4End - step4Start) + "ms");
        
        // Step 5: Create RelatedLinks for this specific privacy variant only
        long step5Start = System.currentTimeMillis();
        createPrivacyRelatedLinksForVariant(privacyLevel);
        long step5End = System.currentTimeMillis();
        logger.info("TIMING: Step 5 (Create links) took " + (step5End - step5Start) + "ms");
        
        long totalTime = System.currentTimeMillis() - startTime;
        logger.info("TIMING: TOTAL import time for " + privacyLevel + ": " + totalTime + "ms");
        
        logger.info("Import completed successfully for privacy variant: " + privacyLevel);
        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().write("Import completed successfully for privacy level: " + privacyLevel);
    }
    
    private String preprocessTaggedUUIDs(String xmlContent, String privacyLevel, Map<String, String> uuidMappings) {
        // Pattern to match tagged UUIDs: urn:uuid:base-uuid-tag
        Pattern taggedUuidPattern = Pattern.compile("urn:uuid:([a-f0-9-]{36})-(" + privacyLevel + ")");
        Matcher matcher = taggedUuidPattern.matcher(xmlContent);
        
        StringBuffer processedXml = new StringBuffer();
        
        while (matcher.find()) {
            String originalTaggedUuid = matcher.group(0); // Full: urn:uuid:base-tag
            String baseUuid = matcher.group(1); // Just the base UUID
            String tag = matcher.group(2); // The privacy tag
            
            // Generate a temporary valid UUID (base UUID + privacy-specific increment)
            String tempUuid = generateTempUuid(baseUuid, privacyLevel);
            String tempUuidUrn = "urn:uuid:" + tempUuid;
            
            // Store mapping for post-processing
            uuidMappings.put(tempUuid, baseUuid + "-" + tag);
            
            logger.debug("Replacing tagged UUID: " + originalTaggedUuid + " -> " + tempUuidUrn);
            
            // Replace in XML
            matcher.appendReplacement(processedXml, tempUuidUrn);
        }
        matcher.appendTail(processedXml);
        
        return processedXml.toString();
    }
    
    private String generateTempUuid(String baseUuid, String privacyLevel) {
        // Take base UUID and modify it uniquely based on privacy level
        char[] chars = baseUuid.toCharArray();
        
        // Map privacy levels to unique increments
        int increment;
        switch (privacyLevel.toLowerCase()) {
            case "full": increment = 1; break;
            case "high": increment = 2; break;
            case "medium": increment = 3; break;
            case "low": increment = 4; break;
            default: increment = 9; break;
        }
        
        // Modify the last character based on privacy level
        char lastChar = chars[chars.length - 1];
        
        if (lastChar >= '0' && lastChar <= '9') {
            int digit = Character.getNumericValue(lastChar);
            chars[chars.length - 1] = Character.forDigit((digit + increment) % 10, 16);
        } else if (lastChar >= 'a' && lastChar <= 'f') {
            int hex = lastChar - 'a' + 10;
            chars[chars.length - 1] = (char)('a' + ((hex + increment) % 6));
        } else {
            // Fallback - just use the increment as hex
            chars[chars.length - 1] = Character.forDigit(increment, 16);
        }
        
        return new String(chars);
    }
    
    private void restoreTaggedUUIDs(Map<String, String> uuidMappings, String privacyLevel) {
        logger.info("Restoring tagged UUIDs for privacy level: " + privacyLevel + ", count: " + uuidMappings.size());
        long restoreStart = System.currentTimeMillis();
        
        for (Map.Entry<String, String> entry : uuidMappings.entrySet()) {
            String tempUuid = entry.getKey();
            String originalTaggedUuid = entry.getValue();
            
            long singleStart = System.currentTimeMillis();
            logger.info("Restoring UUID: " + tempUuid + " -> " + originalTaggedUuid);
            
            try {
                // Use external script to avoid JPA transaction issues
                String scriptPath = "/GBA/OpenESPI-DataCustodian-java/bin/restore_tagged_uuids.sh";
                ProcessBuilder pb = new ProcessBuilder(scriptPath, tempUuid, originalTaggedUuid);
                pb.redirectErrorStream(true);
                
                Process process = pb.start();
                int exitCode = process.waitFor();
                
                // Read the output
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        logger.info("Script output: " + line);
                    }
                }
                
                long singleEnd = System.currentTimeMillis();
                logger.info("TIMING: Single UUID restore took " + (singleEnd - singleStart) + "ms");
                
                if (exitCode == 0) {
                    logger.info("Successfully restored UUID: " + tempUuid + " -> " + originalTaggedUuid);
                } else {
                    logger.error("Script failed with exit code: " + exitCode);
                }
                
            } catch (Exception e) {
                logger.error("Failed to execute UUID restoration script: " + e.getMessage(), e);
            }
        }
        
        long restoreEnd = System.currentTimeMillis();
        logger.info("TIMING: Total UUID restoration took " + (restoreEnd - restoreStart) + "ms for " + uuidMappings.size() + " UUIDs");
        logger.info("Tagged UUID restoration completed for privacy level: " + privacyLevel);
    }
    
    private void createPrivacyRelatedLinksForVariant(String privacyLevel) {
        logger.info("Creating privacy related links for variant: " + privacyLevel);
        
        try {
            // Get the canonical UsagePoint (always ID 1)
            Long canonicalId = 1L;
            String canonicalUuid = "AE0873DC-12F1-4362-93BE-A5A10A903852";
            
            // Map privacy level to expected UsagePoint ID
            Long variantId;
            switch (privacyLevel.toLowerCase()) {
                case "full": variantId = 2L; break;
                case "high": variantId = 3L; break;
                case "medium": variantId = 4L; break;
                case "low": variantId = 5L; break;
                default:
                    logger.warn("Unknown privacy level: " + privacyLevel);
                    return;
            }
            
            // Get the actual UUIDs from database
            String sql = "SELECT uuid FROM usage_points WHERE id = ?";
            Query canonicalQuery = entityManager.createNativeQuery(sql);
            canonicalQuery.setParameter(1, canonicalId);
            String actualCanonicalUuid = (String) canonicalQuery.getSingleResult();
            
            Query variantQuery = entityManager.createNativeQuery(sql);
            variantQuery.setParameter(1, variantId);
            String variantUuid = (String) variantQuery.getSingleResult();
            
            if (actualCanonicalUuid != null && variantUuid != null) {
                logger.info("Creating links: Canonical(" + canonicalId + ", " + actualCanonicalUuid + ") <-> Variant(" + variantId + ", " + variantUuid + ", " + privacyLevel + ")");
                
                try {
                    // Use external script to create privacy links for this specific variant
                    String scriptPath = "/GBA/OpenESPI-DataCustodian-java/bin/create_privacy_links.sh";
                    ProcessBuilder pb = new ProcessBuilder(scriptPath, 
                        canonicalId.toString(), actualCanonicalUuid,
                        variantId.toString(), variantUuid, privacyLevel);
                    pb.redirectErrorStream(true);
                    
                    Process process = pb.start();
                    int exitCode = process.waitFor();
                    
                    // Read the output
                    try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            logger.info("Privacy script output: " + line);
                        }
                    }
                    
                    if (exitCode == 0) {
                        logger.info("Successfully created privacy links for: " + privacyLevel);
                    } else {
                        logger.error("Privacy script failed with exit code: " + exitCode);
                    }
                    
                } catch (Exception e) {
                    logger.error("Failed to execute privacy links script for " + privacyLevel + ": " + e.getMessage(), e);
                }
            } else {
                logger.warn("Could not find UUIDs for canonical(" + canonicalId + ") or variant(" + variantId + ")");
            }
            
        } catch (Exception e) {
            logger.error("Failed to create privacy related links for " + privacyLevel + ": " + e.getMessage(), e);
        }
    }
    
    private String extractPrivacyLevelFromUuid(String uuid) {
        if (uuid.endsWith("-full")) return "full";
        if (uuid.endsWith("-high")) return "high";
        if (uuid.endsWith("-medium")) return "medium";
        if (uuid.endsWith("-low")) return "low";
        return null;
    }
    
    private void createRelatedLink(Long usagePointId, String rel, String href) {
        try {
            // Insert into the usage_point_related_links table
            String sql = "INSERT INTO usage_point_related_links (usage_point_id, rel, href) VALUES (:usagePointId, :rel, :href) " +
                        "ON DUPLICATE KEY UPDATE href = VALUES(href)";
            Query query = entityManager.createNativeQuery(sql);
            query.setParameter("usagePointId", usagePointId);
            query.setParameter("rel", rel);
            query.setParameter("href", href);
            
            query.executeUpdate();
            logger.debug("Created related link: UsagePoint " + usagePointId + " -> " + rel + " -> " + href);
            
        } catch (Exception e) {
            logger.error("Failed to create related link for UsagePoint " + usagePointId + ": " + e.getMessage(), e);
        }
    }

    // Simple ping to verify mapping and to satisfy confusing Allow headers if needed
    @RequestMapping(value = "/import", method = RequestMethod.GET)
    public void importPing(HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use POST with XML body");
    }
}
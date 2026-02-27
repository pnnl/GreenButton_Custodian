-- Placeholder UsagePoint variants for privacy levels
-- This script creates four variant UsagePoints (full, medium, low, high)
-- for every existing canonical UsagePoint. Variants are identified by a
-- UUID suffix: "-full", "-medium", "-low", "-high" and have descriptive
-- titles and self/uri links annotated with a privacy hint.
-- It also adds related links from canonical -> variant (rel = 'privacy:<level>')
-- and from variant -> canonical (rel = 'canonical').
-- Idempotent: safe to run multiple times; it checks for existing UUIDs/links.

SET @now := NOW();

-- Helper: base href builder if self_link_href is NULL
-- We will prefer existing self_link_href of the canonical when available.

-- Create variants: full
INSERT INTO usage_points (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, roleFlags, status, uri, localTimeParameters_id, retail_customer_id,
  serviceCategory_kind, serviceDeliveryPoint_id, subscription_id
)
SELECT
  CONCAT(COALESCE(u.description, ''), CASE WHEN u.description IS NULL OR u.description = '' THEN '' ELSE ' ' END, '[privacy=full]') AS description,
  @now AS published,
  COALESCE(u.self_link_href, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid)),
  u.self_link_rel,
  u.up_link_href,
  u.up_link_rel,
  @now AS updated,
  CONCAT(u.uuid, '-full') AS uuid,
  u.roleFlags,
  u.status,
  COALESCE(u.uri, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid, '/index')),
  u.localTimeParameters_id,
  u.retail_customer_id,
  u.serviceCategory_kind,
  u.serviceDeliveryPoint_id,
  u.subscription_id
FROM usage_points u
LEFT JOIN usage_points v ON v.uuid = CONCAT(u.uuid, '-full')
WHERE v.id IS NULL
  AND u.uuid NOT REGEXP '-(full|medium|low|high)$';

-- Create variants: medium
INSERT INTO usage_points (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, roleFlags, status, uri, localTimeParameters_id, retail_customer_id,
  serviceCategory_kind, serviceDeliveryPoint_id, subscription_id
)
SELECT
  CONCAT(COALESCE(u.description, ''), CASE WHEN u.description IS NULL OR u.description = '' THEN '' ELSE ' ' END, '[privacy=medium]') AS description,
  @now AS published,
  COALESCE(u.self_link_href, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid)),
  u.self_link_rel,
  u.up_link_href,
  u.up_link_rel,
  @now AS updated,
  CONCAT(u.uuid, '-medium') AS uuid,
  u.roleFlags,
  u.status,
  COALESCE(u.uri, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid, '/index')),
  u.localTimeParameters_id,
  u.retail_customer_id,
  u.serviceCategory_kind,
  u.serviceDeliveryPoint_id,
  u.subscription_id
FROM usage_points u
LEFT JOIN usage_points v ON v.uuid = CONCAT(u.uuid, '-medium')
WHERE v.id IS NULL
  AND u.uuid NOT REGEXP '-(full|medium|low|high)$';

-- Create variants: low
INSERT INTO usage_points (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, roleFlags, status, uri, localTimeParameters_id, retail_customer_id,
  serviceCategory_kind, serviceDeliveryPoint_id, subscription_id
)
SELECT
  CONCAT(COALESCE(u.description, ''), CASE WHEN u.description IS NULL OR u.description = '' THEN '' ELSE ' ' END, '[privacy=low]') AS description,
  @now AS published,
  COALESCE(u.self_link_href, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid)),
  u.self_link_rel,
  u.up_link_href,
  u.up_link_rel,
  @now AS updated,
  CONCAT(u.uuid, '-low') AS uuid,
  u.roleFlags,
  u.status,
  COALESCE(u.uri, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid, '/index')),
  u.localTimeParameters_id,
  u.retail_customer_id,
  u.serviceCategory_kind,
  u.serviceDeliveryPoint_id,
  u.subscription_id
FROM usage_points u
LEFT JOIN usage_points v ON v.uuid = CONCAT(u.uuid, '-low')
WHERE v.id IS NULL
  AND u.uuid NOT REGEXP '-(full|medium|low|high)$';

-- Create variants: high
INSERT INTO usage_points (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, roleFlags, status, uri, localTimeParameters_id, retail_customer_id,
  serviceCategory_kind, serviceDeliveryPoint_id, subscription_id
)
SELECT
  CONCAT(COALESCE(u.description, ''), CASE WHEN u.description IS NULL OR u.description = '' THEN '' ELSE ' ' END, '[privacy=high]') AS description,
  @now AS published,
  COALESCE(u.self_link_href, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid)),
  u.self_link_rel,
  u.up_link_href,
  u.up_link_rel,
  @now AS updated,
  CONCAT(u.uuid, '-high') AS uuid,
  u.roleFlags,
  u.status,
  COALESCE(u.uri, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid, '/index')),
  u.localTimeParameters_id,
  u.retail_customer_id,
  u.serviceCategory_kind,
  u.serviceDeliveryPoint_id,
  u.subscription_id
FROM usage_points u
LEFT JOIN usage_points v ON v.uuid = CONCAT(u.uuid, '-high')
WHERE v.id IS NULL
  AND u.uuid NOT REGEXP '-(full|medium|low|high)$';

-- Related links from canonical -> variant
INSERT INTO usage_point_related_links (usage_point_id, href, rel)
SELECT u.id,
       COALESCE(v.self_link_href, CONCAT('/espi/1_1/resource/UsagePoint/', v.uuid)) AS href,
       CONCAT('privacy:', lvl) AS rel
FROM usage_points u
JOIN (
  SELECT 'full' AS lvl UNION ALL SELECT 'medium' UNION ALL SELECT 'low' UNION ALL SELECT 'high'
) l
JOIN usage_points v ON v.uuid = CONCAT(u.uuid, '-', l.lvl)
LEFT JOIN usage_point_related_links rl ON rl.usage_point_id = u.id AND rl.rel = CONCAT('privacy:', l.lvl)
WHERE rl.usage_point_id IS NULL;

-- Reverse links from variant -> canonical
INSERT INTO usage_point_related_links (usage_point_id, href, rel)
SELECT v.id,
       COALESCE(u.self_link_href, CONCAT('/espi/1_1/resource/UsagePoint/', u.uuid)) AS href,
       'canonical' AS rel
FROM usage_points u
JOIN (
  SELECT 'full' AS lvl UNION ALL SELECT 'medium' UNION ALL SELECT 'low' UNION ALL SELECT 'high'
) l
JOIN usage_points v ON v.uuid = CONCAT(u.uuid, '-', l.lvl)
LEFT JOIN usage_point_related_links rl ON rl.usage_point_id = v.id AND rl.rel = 'canonical'
WHERE rl.usage_point_id IS NULL;

-- Optional: minimal placeholder summaries per variant (very lightweight)
-- Creates a single usage_summary row per variant if none exist yet.
INSERT INTO usage_summaries (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, billLastPeriod, billToDate, billingPeriod_duration, billingPeriod_start,
  currency, statusTimeStamp, usage_point_id
)
SELECT
  CONCAT('Placeholder summary for ', v.uuid) AS description,
  @now, NULL, NULL, NULL, NULL,
  @now, CONCAT(v.uuid, ':summary'),
  NULL, NULL, NULL, NULL,
  'USD', UNIX_TIMESTAMP(@now), v.id
FROM usage_points v
LEFT JOIN usage_summaries s ON s.usage_point_id = v.id
WHERE s.id IS NULL
  AND v.uuid REGEXP '-(full|medium|low|high)$';

-- Notes:
-- 1) No meter_readings or interval data are duplicated here; these variants
--    are placeholders for demo/wiring. The DP API will populate data later.
-- 2) UUIDs are unique; running this script again will be a no-op.

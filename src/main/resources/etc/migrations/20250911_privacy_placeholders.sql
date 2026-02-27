-- This file is intentionally a thin wrapper that forwards to the top-level version for dev runs.
-- Keeping a copy on the runtime classpath avoids 404 when running via tomcat7:run.
-- Source of truth lives at project root: etc/migrations/20250911_privacy_placeholders.sql

-- Forward include isn't supported by ScriptUtils; we duplicate the script content below to be self-contained.

SET @now := NOW();

INSERT INTO usage_points (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, roleFlags, status, uri, localTimeParameters_id, retail_customer_id,
  serviceCategory_kind, serviceDeliveryPoint_id, subscription_id
)
SELECT
  CONCAT(COALESCE(u.description, ''), CASE WHEN u.description IS NULL OR u.description = '' THEN '' ELSE ' ' END, '[privacy=full]') AS description,
  @now AS published,
  CONCAT('/espi/1_1/resource/UsagePoint/', CONCAT(u.uuid, '-full')),
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

INSERT INTO usage_points (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, roleFlags, status, uri, localTimeParameters_id, retail_customer_id,
  serviceCategory_kind, serviceDeliveryPoint_id, subscription_id
)
SELECT
  CONCAT(COALESCE(u.description, ''), CASE WHEN u.description IS NULL OR u.description = '' THEN '' ELSE ' ' END, '[privacy=medium]') AS description,
  @now AS published,
  CONCAT('/espi/1_1/resource/UsagePoint/', CONCAT(u.uuid, '-medium')),
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

INSERT INTO usage_points (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, roleFlags, status, uri, localTimeParameters_id, retail_customer_id,
  serviceCategory_kind, serviceDeliveryPoint_id, subscription_id
)
SELECT
  CONCAT(COALESCE(u.description, ''), CASE WHEN u.description IS NULL OR u.description = '' THEN '' ELSE ' ' END, '[privacy=low]') AS description,
  @now AS published,
  CONCAT('/espi/1_1/resource/UsagePoint/', CONCAT(u.uuid, '-low')),
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

INSERT INTO usage_points (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, roleFlags, status, uri, localTimeParameters_id, retail_customer_id,
  serviceCategory_kind, serviceDeliveryPoint_id, subscription_id
)
SELECT
  CONCAT(COALESCE(u.description, ''), CASE WHEN u.description IS NULL OR u.description = '' THEN '' ELSE ' ' END, '[privacy=high]') AS description,
  @now AS published,
  CONCAT('/espi/1_1/resource/UsagePoint/', CONCAT(u.uuid, '-high')),
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

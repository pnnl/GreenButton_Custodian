-- Fix variant self links and related link hrefs; remove orphan summaries; re-add minimal summaries

-- 1) Point variant self_link_href and uri to their own resource path
UPDATE usage_points v
SET v.self_link_href = CONCAT('/espi/1_1/resource/RetailCustomer/', v.retail_customer_id, '/UsagePoint/', v.id),
    v.uri = CONCAT('/espi/1_1/resource/RetailCustomer/', v.retail_customer_id, '/UsagePoint/', v.id)
WHERE v.uuid REGEXP '-(full|medium|low|high)$';

-- 2) Update canonical -> variant related link hrefs to variant self link
UPDATE usage_point_related_links rl
JOIN usage_points u ON rl.usage_point_id = u.id AND u.uuid NOT REGEXP '-(full|medium|low|high)$'
JOIN (
  SELECT v2.id AS vid, v2.uuid, CONCAT('privacy:', SUBSTRING_INDEX(v2.uuid, '-', -1)) AS rel_key, v2.self_link_href AS href
  FROM usage_points v2
  WHERE v2.uuid REGEXP '-(full|medium|low|high)$'
) vv ON rl.rel = vv.rel_key
SET rl.href = vv.href;

-- 3) Update variant -> canonical link hrefs to canonical self link
UPDATE usage_point_related_links rl
JOIN usage_points v ON rl.usage_point_id = v.id AND v.uuid REGEXP '-(full|medium|low|high)$'
JOIN usage_points u ON v.uuid = CONCAT(u.uuid, '-', SUBSTRING_INDEX(v.uuid, '-', -1))
SET rl.href = u.self_link_href
WHERE rl.rel = 'canonical';

-- 4) Remove orphan usage_summaries created when cleaning invalid variants
DELETE s FROM usage_summaries s
LEFT JOIN usage_points up ON up.id = s.usage_point_id
WHERE up.id IS NULL;

-- 5) Ensure exactly one minimal summary per valid variant
INSERT INTO usage_summaries (
  description, published, self_link_href, self_link_rel, up_link_href, up_link_rel,
  updated, uuid, currency, statusTimeStamp, usage_point_id
)
SELECT
  CONCAT('Placeholder summary for ', v.uuid) AS description,
  NOW(), NULL, NULL, NULL, NULL,
  NOW(), CONCAT(v.uuid, ':summary'), 'USD', UNIX_TIMESTAMP(NOW()), v.id
FROM usage_points v
LEFT JOIN usage_summaries s ON s.usage_point_id = v.id
WHERE v.uuid REGEXP '-(full|medium|low|high)$'
  AND s.id IS NULL;

-- Cleanup any variants-of-variants introduced by earlier runs
-- Remove rows whose UUID contains multiple level suffixes like '-full-low'

-- Delete links that point from or to such invalid variants first
DELETE rl FROM usage_point_related_links rl
JOIN usage_points up ON rl.usage_point_id = up.id
WHERE up.uuid REGEXP '-(full|medium|low|high).*(full|medium|low|high)$';

-- Delete invalid variant usage_points
DELETE v FROM usage_points v
WHERE v.uuid REGEXP '-(full|medium|low|high).*(full|medium|low|high)$';

-- Rebuild missing related links for valid variants
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
WHERE u.uuid NOT REGEXP '-(full|medium|low|high)$'
  AND rl.usage_point_id IS NULL;

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
WHERE u.uuid NOT REGEXP '-(full|medium|low|high)$'
  AND rl.usage_point_id IS NULL;

-- Privacy level setup for DataCustodian
-- Adds a column to store the consented privacy level and triggers to derive it from the OAuth scope.
-- Also seeds privacy scopes for existing clients for testing/demo.

-- 1) Schema: add privacy_level to authorizations
ALTER TABLE `authorizations`
  ADD COLUMN `privacy_level` VARCHAR(16) NULL AFTER `scope`;

-- 2) Triggers: derive privacy_level from scope on INSERT/UPDATE
DELIMITER $$
CREATE TRIGGER `authorizations_set_privacy_before_insert`
BEFORE INSERT ON `authorizations`
FOR EACH ROW
BEGIN
  SET NEW.privacy_level =
    CASE
      WHEN NEW.scope LIKE '%privacy:full%' THEN 'full'
      WHEN NEW.scope LIKE '%privacy:medium%' THEN 'medium'
      WHEN NEW.scope LIKE '%privacy:low%' THEN 'low'
      WHEN NEW.scope LIKE '%privacy:high%' THEN 'high'
      ELSE NULL
    END;
END$$

CREATE TRIGGER `authorizations_set_privacy_before_update`
BEFORE UPDATE ON `authorizations`
FOR EACH ROW
BEGIN
  SET NEW.privacy_level =
    CASE
      WHEN NEW.scope LIKE '%privacy:full%' THEN 'full'
      WHEN NEW.scope LIKE '%privacy:medium%' THEN 'medium'
      WHEN NEW.scope LIKE '%privacy:low%' THEN 'low'
      WHEN NEW.scope LIKE '%privacy:high%' THEN 'high'
      ELSE NEW.privacy_level
    END;
END$$
DELIMITER ;

-- 3) Seed privacy scopes for all registered clients (non-destructive)
INSERT INTO `application_information_scopes` (`application_information_id`, `scope`)
  SELECT `id`, 'privacy:full' FROM `application_information`;
INSERT INTO `application_information_scopes` (`application_information_id`, `scope`)
  SELECT `id`, 'privacy:medium' FROM `application_information`;
INSERT INTO `application_information_scopes` (`application_information_id`, `scope`)
  SELECT `id`, 'privacy:low' FROM `application_information`;
INSERT INTO `application_information_scopes` (`application_information_id`, `scope`)
  SELECT `id`, 'privacy:high' FROM `application_information`;

-- Note: If you want to scope these to a single client, add WHERE clientId='your_client_id' to the SELECTs above.

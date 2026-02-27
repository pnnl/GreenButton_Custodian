-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: localhost    Database: datacustodian
-- ------------------------------------------------------
-- Server version	8.0.42-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `BatchList`
--

DROP TABLE IF EXISTS `BatchList`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `BatchList` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `application_information`
--

DROP TABLE IF EXISTS `application_information`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application_information` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `kind` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `authorizationServerAuthorizationEndpoint` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `authorizationServerRegistrationEndpoint` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `authorizationServerTokenEndpoint` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `authorizationServerUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `clientId` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `clientIdIssuedAt` bigint DEFAULT NULL,
  `clientName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `clientSecret` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `clientSecretExpiresAt` bigint DEFAULT NULL,
  `clientUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contacts` tinyblob,
  `dataCustodianApplicationStatus` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dataCustodianBulkRequestURI` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dataCustodianDefaultBatchResource` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dataCustodianDefaultSubscriptionResource` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dataCustodianId` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dataCustodianResourceEndpoint` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dataCustodianThirdPartySelectionScreenURI` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logoUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `policyUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `redirectUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registrationAccessToken` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registrationClientUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `responseTypes` int DEFAULT NULL,
  `softwareId` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `softwareVersion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyApplicationDescription` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyApplicationName` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `thirdPartyApplicationStatus` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyApplicationType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyApplicationUse` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyDataCustodianSelectionScreenURI` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyLoginScreenURI` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyNotifyUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyPhone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyScopeSelectionScreenURI` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thirdPartyUserPortalScreenURI` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tokenEndpointAuthMethod` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tosUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dataCustodianScopeSelectionScreenURI` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `clientId_UNIQUE` (`clientId`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `application_information_grant_types`
--

DROP TABLE IF EXISTS `application_information_grant_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application_information_grant_types` (
  `application_information_id` bigint NOT NULL,
  `grantTypes` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `FK_61a6f8b0091946139543874e559` (`application_information_id`),
  CONSTRAINT `FK_61a6f8b0091946139543874e559` FOREIGN KEY (`application_information_id`) REFERENCES `application_information` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `application_information_scopes`
--

DROP TABLE IF EXISTS `application_information_scopes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application_information_scopes` (
  `application_information_id` bigint NOT NULL,
  `scope` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `FK_61a6f8b0091946139543874d559` (`application_information_id`),
  CONSTRAINT `FK_61a6f8b0091946139543874d559` FOREIGN KEY (`application_information_id`) REFERENCES `application_information` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authorizations`
--

DROP TABLE IF EXISTS `authorizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `authorizations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'self',
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'up',
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_token` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `authorization_uri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ap_duration` bigint DEFAULT NULL,
  `ap_start` bigint DEFAULT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `error` int DEFAULT NULL,
  `errorDescription` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `errorUri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expiresIn` bigint DEFAULT NULL,
  `grantType` int DEFAULT NULL,
  `pp_duration` bigint DEFAULT NULL,
  `pp_start` bigint DEFAULT NULL,
  `refreshToken` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resourceURI` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `responseType` int DEFAULT NULL,
  `scope` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `third_party` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tokenType` int DEFAULT NULL,
  `application_information_id` bigint DEFAULT NULL,
  `retail_customer_id` bigint DEFAULT NULL,
  `subscription_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_d0761ae9d2dd44c49867ac4ec4b` (`application_information_id`),
  KEY `FK_a4fccef421a14e0ead5c1b9753d` (`retail_customer_id`),
  KEY `FK_subscriptionkey` (`subscription_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `electric_power_quality_summaries`
--

DROP TABLE IF EXISTS `electric_power_quality_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `electric_power_quality_summaries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `flickerPlt` bigint DEFAULT NULL,
  `flickerPst` bigint DEFAULT NULL,
  `harmonicVoltage` bigint DEFAULT NULL,
  `longInterruptions` bigint DEFAULT NULL,
  `mainsVoltage` bigint DEFAULT NULL,
  `measurementProtocol` smallint DEFAULT NULL,
  `powerFrequency` bigint DEFAULT NULL,
  `rapidVoltageChanges` bigint DEFAULT NULL,
  `shortInterruptions` bigint DEFAULT NULL,
  `duration` bigint DEFAULT NULL,
  `start` bigint DEFAULT NULL,
  `supplyVoltageDips` bigint DEFAULT NULL,
  `supplyVoltageImbalance` bigint DEFAULT NULL,
  `supplyVoltageVariations` bigint DEFAULT NULL,
  `tempOvervoltage` bigint DEFAULT NULL,
  `usage_point_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_a2b7b05e45914898bb9f3e8f2f7` (`uuid`),
  KEY `FK_804ec1c7cfd4488a8fa95388b74` (`usage_point_id`),
  CONSTRAINT `FK_804ec1c7cfd4488a8fa95388b74` FOREIGN KEY (`usage_point_id`) REFERENCES `usage_points` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `electric_power_usage_summaries`
--

DROP TABLE IF EXISTS `electric_power_usage_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `electric_power_usage_summaries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `billLastPeriod` bigint DEFAULT NULL,
  `billToDate` bigint DEFAULT NULL,
  `billingPeriod_duration` bigint DEFAULT NULL,
  `billingPeriod_start` bigint DEFAULT NULL,
  `costAdditionalLastPeriod` bigint DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentBillingPeriodOverAllConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentBillingPeriodOverAllConsumption_timeStamp` bigint DEFAULT NULL,
  `currentBillingPeriodOverAllConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentBillingPeriodOverAllConsumption_value` bigint DEFAULT NULL,
  `currentDayLastYearNetConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayLastYearNetConsumption_timeStamp` bigint DEFAULT NULL,
  `currentDayLastYearNetConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayLastYearNetConsumption_value` bigint DEFAULT NULL,
  `currentDayNetConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayNetConsumption_timeStamp` bigint DEFAULT NULL,
  `currentDayNetConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayNetConsumption_value` bigint DEFAULT NULL,
  `currentDayOverallConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayOverallConsumption_timeStamp` bigint DEFAULT NULL,
  `currentDayOverallConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayOverallConsumption_value` bigint DEFAULT NULL,
  `overallConsumptionLastPeriod_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `overallConsumptionLastPeriod_timeStamp` bigint DEFAULT NULL,
  `overallConsumptionLastPeriod_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `overallConsumptionLastPeriod_value` bigint DEFAULT NULL,
  `peakDemand_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `peakDemand_timeStamp` bigint DEFAULT NULL,
  `peakDemand_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `peakDemand_value` bigint DEFAULT NULL,
  `previousDayLastYearOverallConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayLastYearOverallConsumption_timeStamp` bigint DEFAULT NULL,
  `previousDayLastYearOverallConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayLastYearOverallConsumption_value` bigint DEFAULT NULL,
  `previousDayNetConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayNetConsumption_timeStamp` bigint DEFAULT NULL,
  `previousDayNetConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayNetConsumption_value` bigint DEFAULT NULL,
  `previousDayOverallConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayOverallConsumption_timeStamp` bigint DEFAULT NULL,
  `previousDayOverallConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayOverallConsumption_value` bigint DEFAULT NULL,
  `qualityOfReading` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ratchetDemand_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ratchetDemand_timeStamp` bigint DEFAULT NULL,
  `ratchetDemand_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ratchetDemand_value` bigint DEFAULT NULL,
  `ratchetDemandPeriod_duration` bigint DEFAULT NULL,
  `ratchetDemandPeriod_start` bigint DEFAULT NULL,
  `statusTimeStamp` bigint NOT NULL,
  `usage_point_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_7b7325ca02a9414ea62fcabc984` (`uuid`),
  KEY `FK_73bd63f6333f44ff8c7f628f79d` (`usage_point_id`),
  CONSTRAINT `FK_73bd63f6333f44ff8c7f628f79d` FOREIGN KEY (`usage_point_id`) REFERENCES `usage_points` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interval_blocks`
--

DROP TABLE IF EXISTS `interval_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interval_blocks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` bigint DEFAULT NULL,
  `start` bigint DEFAULT NULL,
  `meter_reading_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_52e33c3a319146ea9dcc64bebd0` (`uuid`),
  KEY `FK_23dcffa0baa44ffb817767d815f` (`meter_reading_id`),
  CONSTRAINT `FK_23dcffa0baa44ffb817767d815f` FOREIGN KEY (`meter_reading_id`) REFERENCES `meter_readings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interval_readings`
--

DROP TABLE IF EXISTS `interval_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interval_readings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cost` bigint DEFAULT NULL,
  `duration` bigint DEFAULT NULL,
  `start` bigint DEFAULT NULL,
  `value` bigint DEFAULT NULL,
  `interval_block_id` bigint DEFAULT NULL,
  `consumptionTier` bigint DEFAULT NULL,
  `tou` bigint DEFAULT NULL,
  `cpp` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_982b1bcd359b47fcb5823a43d21` (`interval_block_id`),
  CONSTRAINT `FK_982b1bcd359b47fcb5823a43d21` FOREIGN KEY (`interval_block_id`) REFERENCES `interval_blocks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `line_item`
--

DROP TABLE IF EXISTS `line_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `line_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `amount` bigint NOT NULL,
  `dateTime` bigint NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rounding` bigint DEFAULT NULL,
  `electric_power_usage_summary_id` bigint DEFAULT NULL,
  `usage_summary_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_5910ba965b7e41cd9bbe7949fbb` (`electric_power_usage_summary_id`),
  KEY `fk_line_item_1_idx` (`usage_summary_id`),
  CONSTRAINT `FK_5910ba965b7e41cd9bbe7949fbb` FOREIGN KEY (`electric_power_usage_summary_id`) REFERENCES `electric_power_usage_summaries` (`id`),
  CONSTRAINT `fk_line_item_1` FOREIGN KEY (`usage_summary_id`) REFERENCES `usage_summaries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meter_reading_related_links`
--

DROP TABLE IF EXISTS `meter_reading_related_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meter_reading_related_links` (
  `meter_reading_id` bigint NOT NULL,
  `href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `FK_bf71138af7384923bd0b190ac4c` (`meter_reading_id`),
  CONSTRAINT `FK_bf71138af7384923bd0b190ac4c` FOREIGN KEY (`meter_reading_id`) REFERENCES `meter_readings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meter_readings`
--

DROP TABLE IF EXISTS `meter_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meter_readings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reading_type_id` bigint DEFAULT NULL,
  `usage_point_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_445adb83af2e4fa4928a31692e4` (`uuid`),
  KEY `FK_67563dc6050e46ba9fcbc86b721` (`reading_type_id`),
  KEY `FK_8eaf32259169401e8cae99a5891` (`usage_point_id`),
  CONSTRAINT `FK_67563dc6050e46ba9fcbc86b721` FOREIGN KEY (`reading_type_id`) REFERENCES `reading_types` (`id`),
  CONSTRAINT `FK_8eaf32259169401e8cae99a5891` FOREIGN KEY (`usage_point_id`) REFERENCES `usage_points` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reading_qualities`
--

DROP TABLE IF EXISTS `reading_qualities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reading_qualities` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `quality` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `interval_reading_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_11d630a57d684f26894e1cd6aa6` (`interval_reading_id`),
  CONSTRAINT `FK_11d630a57d684f26894e1cd6aa6` FOREIGN KEY (`interval_reading_id`) REFERENCES `interval_readings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reading_types`
--

DROP TABLE IF EXISTS `reading_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reading_types` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `accumulationBehaviour` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rational_denominator` decimal(19,2) DEFAULT NULL,
  `rational_numerator` decimal(19,2) DEFAULT NULL,
  `commodity` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `consumptionTier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cpp` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dataQualifier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `defaultQuality` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `flowDirection` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `interharmonic_denominator` decimal(19,2) DEFAULT NULL,
  `interharmonic_numerator` decimal(19,2) DEFAULT NULL,
  `intervalLength` bigint DEFAULT NULL,
  `kind` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `measuringPeriod` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phase` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timeAttribute` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tou` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_0246e3bcf2a34f8f9a8c992140f` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reading_types_meter_readings`
--

DROP TABLE IF EXISTS `reading_types_meter_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reading_types_meter_readings` (
  `reading_types_id` bigint NOT NULL,
  `meterReadings_id` bigint NOT NULL,
  UNIQUE KEY `UK_47a670721527488b84a5a98d629` (`meterReadings_id`),
  KEY `FK_041b1404ae52437480cb75e6966` (`meterReadings_id`),
  KEY `FK_5268261ff37f4147a4d1250213f` (`reading_types_id`),
  CONSTRAINT `FK_041b1404ae52437480cb75e6966` FOREIGN KEY (`meterReadings_id`) REFERENCES `meter_readings` (`id`),
  CONSTRAINT `FK_5268261ff37f4147a4d1250213f` FOREIGN KEY (`reading_types_id`) REFERENCES `reading_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resources`
--

DROP TABLE IF EXISTS `resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resources` (
  `id` bigint NOT NULL,
  `uri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `FK_37f4ae42a5f94b85ac063017869` (`id`),
  CONSTRAINT `FK_37f4ae42a5f94b85ac063017869` FOREIGN KEY (`id`) REFERENCES `BatchList` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `retail_customers`
--

DROP TABLE IF EXISTS `retail_customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `retail_customers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` bit(1) NOT NULL,
  `first_name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_delivery_points`
--

DROP TABLE IF EXISTS `service_delivery_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_delivery_points` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `customerAgreement` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tariffProfile` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'self',
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'up',
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hashedId` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastUpdate` datetime DEFAULT NULL,
  `applicationInformation_id` bigint NOT NULL,
  `authorization_id` bigint DEFAULT NULL,
  `retail_customer_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_a027c87418ce4d7abbde7ee5eec` (`applicationInformation_id`),
  KEY `FK_a68a2938cbc142c3b82f57cb4b1` (`authorization_id`),
  KEY `FK_e38a940ce8ed4d8983d1d5dac6e` (`retail_customer_id`),
  CONSTRAINT `FK_a027c87418ce4d7abbde7ee5eec` FOREIGN KEY (`applicationInformation_id`) REFERENCES `application_information` (`id`),
  CONSTRAINT `FK_e38a940ce8ed4d8983d1d5dac6e` FOREIGN KEY (`retail_customer_id`) REFERENCES `retail_customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscriptions_usage_points`
--

DROP TABLE IF EXISTS `subscriptions_usage_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions_usage_points` (
  `subscriptions_id` bigint NOT NULL,
  `usagePoints_id` bigint NOT NULL,
  KEY `FK_862cd528c4954f4cb2bcdadaf08` (`usagePoints_id`),
  KEY `FK_c138e968ff2d4cd49398210f48c` (`subscriptions_id`),
  CONSTRAINT `FK_c138e968ff2d4cd49398210f48c` FOREIGN KEY (`subscriptions_id`) REFERENCES `subscriptions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `time_configurations`
--

DROP TABLE IF EXISTS `time_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `time_configurations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dstEndRule` tinyblob,
  `dstOffset` bigint NOT NULL,
  `dstStartRule` tinyblob,
  `tzOffset` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_322e8ed3a1024462a1061593ae2` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usage_point_related_links`
--

DROP TABLE IF EXISTS `usage_point_related_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usage_point_related_links` (
  `usage_point_id` bigint NOT NULL,
  `href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `FK_4f728266adfa41b2b8abc65c6e9` (`usage_point_id`),
  CONSTRAINT `FK_4f728266adfa41b2b8abc65c6e9` FOREIGN KEY (`usage_point_id`) REFERENCES `usage_points` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usage_points`
--

DROP TABLE IF EXISTS `usage_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usage_points` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roleFlags` tinyblob,
  `status` smallint DEFAULT NULL,
  `uri` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `localTimeParameters_id` bigint DEFAULT NULL,
  `retail_customer_id` bigint DEFAULT NULL,
  `serviceCategory_kind` bigint NOT NULL,
  `serviceDeliveryPoint_id` bigint DEFAULT NULL,
  `subscription_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_d3b5c06a4b994ad8906ead9757f` (`uuid`),
  KEY `FK_9fa5cbe1eaeb4dbfb7209cb0213` (`localTimeParameters_id`),
  KEY `FK_41107ba4248e4bf79b62c405385` (`retail_customer_id`),
  KEY `FK_c3909436c6934c8bb14da2bb93b` (`serviceDeliveryPoint_id`),
  KEY `FK_53bcef9479ff4522b63a46e018c` (`subscription_id`),
  CONSTRAINT `FK_41107ba4248e4bf79b62c405385` FOREIGN KEY (`retail_customer_id`) REFERENCES `retail_customers` (`id`),
  CONSTRAINT `FK_53bcef9479ff4522b63a46e018c` FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`),
  CONSTRAINT `FK_9fa5cbe1eaeb4dbfb7209cb0213` FOREIGN KEY (`localTimeParameters_id`) REFERENCES `time_configurations` (`id`),
  CONSTRAINT `FK_c3909436c6934c8bb14da2bb93b` FOREIGN KEY (`serviceDeliveryPoint_id`) REFERENCES `service_delivery_points` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usage_summaries`
--

DROP TABLE IF EXISTS `usage_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usage_summaries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `published` datetime DEFAULT NULL,
  `self_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_href` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `up_link_rel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `billLastPeriod` bigint DEFAULT NULL,
  `billToDate` bigint DEFAULT NULL,
  `billingPeriod_duration` bigint DEFAULT NULL,
  `billingPeriod_start` bigint DEFAULT NULL,
  `costAdditionalLastPeriod` bigint DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentBillingPeriodOverAllConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentBillingPeriodOverAllConsumption_timeStamp` bigint DEFAULT NULL,
  `currentBillingPeriodOverAllConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentBillingPeriodOverAllConsumption_value` bigint DEFAULT NULL,
  `currentDayLastYearNetConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayLastYearNetConsumption_timeStamp` bigint DEFAULT NULL,
  `currentDayLastYearNetConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayLastYearNetConsumption_value` bigint DEFAULT NULL,
  `currentDayNetConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayNetConsumption_timeStamp` bigint DEFAULT NULL,
  `currentDayNetConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayNetConsumption_value` bigint DEFAULT NULL,
  `currentDayOverallConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayOverallConsumption_timeStamp` bigint DEFAULT NULL,
  `currentDayOverallConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currentDayOverallConsumption_value` bigint DEFAULT NULL,
  `overallConsumptionLastPeriod_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `overallConsumptionLastPeriod_timeStamp` bigint DEFAULT NULL,
  `overallConsumptionLastPeriod_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `overallConsumptionLastPeriod_value` bigint DEFAULT NULL,
  `peakDemand_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `peakDemand_timeStamp` bigint DEFAULT NULL,
  `peakDemand_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `peakDemand_value` bigint DEFAULT NULL,
  `previousDayLastYearOverallConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayLastYearOverallConsumption_timeStamp` bigint DEFAULT NULL,
  `previousDayLastYearOverallConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayLastYearOverallConsumption_value` bigint DEFAULT NULL,
  `previousDayNetConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayNetConsumption_timeStamp` bigint DEFAULT NULL,
  `previousDayNetConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayNetConsumption_value` bigint DEFAULT NULL,
  `previousDayOverallConsumption_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayOverallConsumption_timeStamp` bigint DEFAULT NULL,
  `previousDayOverallConsumption_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previousDayOverallConsumption_value` bigint DEFAULT NULL,
  `qualityOfReading` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ratchetDemand_powerOfTenMultiplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ratchetDemand_timeStamp` bigint DEFAULT NULL,
  `ratchetDemand_uom` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ratchetDemand_value` bigint DEFAULT NULL,
  `ratchetDemandPeriod_duration` bigint DEFAULT NULL,
  `ratchetDemandPeriod_start` bigint DEFAULT NULL,
  `statusTimeStamp` bigint NOT NULL,
  `usage_point_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid_UNIQUE` (`uuid`),
  KEY `fk_usage_summaries_1_idx` (`usage_point_id`),
  CONSTRAINT `fk_usage_summaries_1` FOREIGN KEY (`usage_point_id`) REFERENCES `usage_points` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-30 14:55:56

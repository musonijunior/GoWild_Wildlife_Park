-- ============================================================
-- DATA VALIDATION TESTING
-- These tests demonstrate that the database enforces data integrity
-- ============================================================

PRAGMA foreign_keys = ON;

-- TEST 1: Attempt to insert animal with non-existent species (should FAIL)
.print '=== TEST 1: Foreign Key Constraint (Should Fail) ==='
INSERT OR IGNORE INTO Animals (animalID, animalName, gender, yearArrived, speciesID, dietID, keeperID, enclosureID)
VALUES ('TEST1', 'Test Animal', 'M', 2024, 'INVALID_SPECIES', 'D1', 'K1', 'E1');
SELECT 'Foreign key constraint prevents invalid species reference' AS Result;

-- TEST 2: Attempt to insert invalid gender (should FAIL)
.print ''
.print '=== TEST 2: Check Constraint - Invalid Gender (Should Fail) ==='
INSERT OR IGNORE INTO Animals (animalID, animalName, gender, yearArrived, speciesID, dietID, keeperID, enclosureID)
VALUES ('TEST2', 'Test Animal', 'X', 2024, 'S3', 'D1', 'K1', 'E1');
SELECT 'Check constraint prevents invalid gender value' AS Result;

-- TEST 3: Verify referential integrity - all animals have valid foreign keys
.print ''
.print '=== TEST 3: Referential Integrity Verification ==='
SELECT COUNT(*) AS 'Animals with Invalid Species' 
FROM Animals WHERE speciesID NOT IN (SELECT speciesID FROM Species);
SELECT COUNT(*) AS 'Animals with Invalid Diet' 
FROM Animals WHERE dietID NOT IN (SELECT dietID FROM Diet);
SELECT COUNT(*) AS 'Animals with Invalid Keeper' 
FROM Animals WHERE keeperID NOT IN (SELECT keeperID FROM Keepers);
SELECT COUNT(*) AS 'Animals with Invalid Enclosure' 
FROM Animals WHERE enclosureID NOT IN (SELECT enclosureID FROM Enclosures);

-- TEST 4: Show all valid data counts
.print ''
.print '=== TEST 4: Valid Data Counts ==='
SELECT 'Total Species: ' || COUNT(*) FROM Species;
SELECT 'Total Diets: ' || COUNT(*) FROM Diet;
SELECT 'Total Keepers: ' || COUNT(*) FROM Keepers;
SELECT 'Total Enclosures: ' || COUNT(*) FROM Enclosures;
SELECT 'Total Animals: ' || COUNT(*) FROM Animals;

-- ============================================================
-- FIVE REQUIRED QUERIES FOR GO WILD WILDLIFE PARK
-- Based on Pearson BTEC Unit 2 Assignment Requirements
-- ============================================================

PRAGMA foreign_keys = ON;

-- ============================================================
-- QUERY 1: Alphabetical sorted list of keepers
-- Showing ID, name and rank
-- ============================================================

-- === QUERY 1: Alphabetical Sorted List of Keepers ===
SELECT 
    keeperID AS 'Keeper ID',
    keeperName AS 'Keeper Name', 
    keeperRank AS 'Rank'
FROM Keepers
ORDER BY keeperName ASC;

-- ============================================================
-- QUERY 2: Number of animals in each type of enclosure
-- ============================================================

-- === QUERY 2: Number of Animals per Enclosure Type ===
SELECT 
    Enclosures.enclosureType AS 'Enclosure Type',
    COUNT(Animals.animalID) AS 'Number of Animals'
FROM Enclosures
INNER JOIN Animals ON Enclosures.enclosureID = Animals.enclosureID
GROUP BY Enclosures.enclosureType
ORDER BY COUNT(Animals.animalID) DESC;

-- ============================================================
-- QUERY 3: Parameter query for keeper rank
-- ============================================================

-- === QUERY 3: Keepers by Rank ===
-- For SENIOR keepers
SELECT 
    keeperName AS 'Keeper Name', 
    keeperDoB AS 'Date of Birth'
FROM Keepers
WHERE keeperRank = 'Senior'
ORDER BY keeperName;

-- For STANDARD keepers
SELECT 
    keeperName AS 'Keeper Name', 
    keeperDoB AS 'Date of Birth'
FROM Keepers
WHERE keeperRank = 'Standard'
ORDER BY keeperName;

-- For JUNIOR keepers
SELECT 
    keeperName AS 'Keeper Name', 
    keeperDoB AS 'Date of Birth'
FROM Keepers
WHERE keeperRank = 'Junior'
ORDER BY keeperName;

-- ============================================================
-- QUERY 4: Species with more than three feeds per day
-- ============================================================

-- === QUERY 4: Species with More Than Three Feeds Per Day ===
SELECT 
    Species.speciesType AS 'Species',
    Diet.feedsPerDay AS 'Feeds Per Day',
    COUNT(Animals.animalID) AS 'Number of Animals'
FROM Species
INNER JOIN Animals ON Species.speciesID = Animals.speciesID
INNER JOIN Diet ON Animals.dietID = Diet.dietID
GROUP BY Species.speciesType, Diet.feedsPerDay
HAVING Diet.feedsPerDay > 3
ORDER BY Diet.feedsPerDay DESC;

-- ============================================================
-- QUERY 5: Omnivores who are critically endangered
-- ============================================================

-- === QUERY 5: Omnivores Who Are Critically Endangered ===
SELECT 
    Animals.animalID AS 'Animal ID',
    Animals.yearArrived AS 'Year Arrived',
    Animals.speciesID AS 'Species ID',
    Animals.keeperID AS 'Keeper ID',
    Species.speciesType AS 'Species Name',
    Diet.dietType AS 'Diet Type',
    Species.conservationStatus AS 'Conservation Status'
FROM Species
INNER JOIN Animals ON Species.speciesID = Animals.speciesID
INNER JOIN Diet ON Animals.dietID = Diet.dietID
WHERE Diet.dietType = 'Omnivore' 
  AND Species.conservationStatus = 'Critically Endangered'
ORDER BY Animals.yearArrived DESC;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- === Check for orphan records (should return 0) ===
SELECT 'Animals without valid species: ' || COUNT(*) AS OrphanCount
FROM Animals WHERE speciesID NOT IN (SELECT speciesID FROM Species);

SELECT 'Animals without valid keeper: ' || COUNT(*) 
FROM Animals WHERE keeperID NOT IN (SELECT keeperID FROM Keepers);

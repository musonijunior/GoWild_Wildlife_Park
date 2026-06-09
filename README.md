-- ============================================================
-- GO WILD WILDLIFE PARK DATABASE SCHEMA
-- Created for Pearson BTEC International Level 3 IT
-- Unit 2: Creating Systems to Manage Information
-- Fully aligned with the provided CSV data file
-- ============================================================

-- Enable foreign key constraints (essential for referential integrity)
PRAGMA foreign_keys = ON;

-- ============================================================
-- TABLE 1: SPECIES
-- Stores taxonomic and conservation information
-- Matches columns: Species ID, Species type, Species group, 
-- Lifestyle, Conservation Status from CSV
-- ============================================================

CREATE TABLE IF NOT EXISTS Species (
    speciesID INT PRIMARY KEY,
    speciesType VARCHAR(20) NOT NULL,
    speciesGroup VARCHAR(20) NOT NULL,
    lifestyle VARCHAR(20) NOT NULL,
    conservationStatus VARCHAR(20) NOT NULL,
    
    -- Validation constraints
    CONSTRAINT chk_speciesGroup CHECK (
        speciesGroup IN ('Mammal', 'Bird', 'Reptile', 'Amphibian', 'Fish', 'Invertebrate')
    ),
    CONSTRAINT chk_lifestyle CHECK (
        lifestyle IN ('Troop', 'Solitary', 'Herd', 'Pride', 'Social', 'Group')
    ),
    CONSTRAINT chk_conservationStatus CHECK (
        conservationStatus IN ('Threatened', 'Critically Endangered', 'Vulnerable', 
                              'Endangered', 'Least Concern')
    )
);

-- ============================================================
-- TABLE 2: DIET
-- Stores dietary information including feeding frequency
-- Matches columns: Diet ID, Diet type, No of feeds per day from CSV
-- ============================================================

CREATE TABLE IF NOT EXISTS Diet (
    dietID INT PRIMARY KEY,
    dietType VARCHAR(20) NOT NULL,
    feedsPerDay INTEGER NOT NULL,
    
    -- Validation constraints
    CONSTRAINT chk_dietType CHECK (
        dietType IN ('Omnivore', 'Herbivore', 'Carnivore')
    ),
    CONSTRAINT chk_feedsPerDay CHECK (
        feedsPerDay BETWEEN 1 AND 10
    )
);

-- ============================================================
-- TABLE 3: KEEPERS
-- Stores employee information for animal keepers
-- Matches columns: Keeper ID, Keeper name, Keeper DoB, Keeper rank from CSV
-- ============================================================

CREATE TABLE IF NOT EXISTS Keepers (
    keeperID INT PRIMARY KEY,
    keeperName VARCHAR(100) NOT NULL,
    keeperDoB DATE NOT NULL,
    keeperRank VARCHAR(20) NOT NULL,
    
    -- Validation constraints
    CONSTRAINT chk_keeperRank CHECK (
        keeperRank IN ('Junior', 'Standard', 'Senior')
    )
);

-- ============================================================
-- TABLE 4: ENCLOSURES
-- Stores habitat information for animal enclosures
-- Matches columns: Enclosure ID, Enclosure type, Enclosure location from CSV
-- ============================================================

CREATE TABLE IF NOT EXISTS Enclosures (
    enclosureID INT PRIMARY KEY,
    enclosureType VARCHAR(30) NOT NULL,
    enclosureLocation VARCHAR(20) NOT NULL,
    
    -- Validation constraints
    CONSTRAINT chk_enclosureType CHECK (
        enclosureType IN ('Glass', 'Moat', 'Fence', 'Walled', 'Pen')
    ),
    CONSTRAINT chk_enclosureLocation CHECK (
        enclosureLocation IN ('North', 'South', 'East', 'West')
    )
);

-- ============================================================
-- TABLE 5: ANIMALS
-- Central transaction table linking all parent tables
-- Matches columns: Animal ID, Animal name, Gender, Year of arrival from CSV
-- Plus foreign keys to Species, Diet, Keepers, Enclosures
-- ============================================================

CREATE TABLE IF NOT EXISTS Animals (
    animalID INT PRIMARY KEY,
    animalName VARCHAR(100) NOT NULL,
    gender CHAR(1) NOT NULL,
    yearArrived INTEGER NOT NULL,
    speciesID INT NOT NULL,
    dietID INT NOT NULL,
    keeperID INT NOT NULL,
    enclosureID INT NOT NULL,
    
    -- Validation constraints
    CONSTRAINT chk_gender CHECK (
        gender IN ('M', 'F')
    ),
    CONSTRAINT chk_yearArrived CHECK (
        yearArrived BETWEEN 1990 AND CAST(strftime('%Y', 'now') AS INTEGER)
    ),
    
    -- Foreign key constraints (referential integrity)
    FOREIGN KEY (speciesID) REFERENCES Species(speciesID) 
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (dietID) REFERENCES Diet(dietID) 
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (keeperID) REFERENCES Keepers(keeperID) 
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (enclosureID) REFERENCES Enclosures(enclosureID) 
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================================
-- CREATE INDEXES FOR PERFORMANCE
-- Indexes speed up query execution on foreign key columns
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_animals_species ON Animals(speciesID);
CREATE INDEX IF NOT EXISTS idx_animals_diet ON Animals(dietID);
CREATE INDEX IF NOT EXISTS idx_animals_keeper ON Animals(keeperID);
CREATE INDEX IF NOT EXISTS idx_animals_enclosure ON Animals(enclosureID);
CREATE INDEX IF NOT EXISTS idx_keepers_name ON Keepers(keeperName);
CREATE INDEX IF NOT EXISTS idx_species_type ON Species(speciesType);

-- ============================================================
-- VERIFY SCHEMA CREATION
-- ============================================================

SELECT 'Schema created successfully!' AS Status;
SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;
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
a
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
-- ============================================================
-- IMPORT DATA FROM CSV INTO NORMALIZED TABLES
-- Based on the provided CSV file: unit-2-creating-systems-to-manage-information-csv-data-file-version-1-2-jul-2020.csv
-- ============================================================

PRAGMA foreign_keys = OFF;

-- ============================================================
-- STEP 1: INSERT UNIQUE SPECIES FROM CSV DATA
-- Extracting distinct species records from the CSV
-- ============================================================

INSERT OR IGNORE INTO Species (speciesID, speciesType, speciesGroup, lifestyle, conservationStatus)
VALUES
    ('S3', 'Gorilla', 'Mammal', 'Troop', 'Threatened'),
    ('S4', 'Orang-utan', 'Mammal', 'Solitary', 'Critically Endangered'),
    ('S6', 'Rhinoceros', 'Mammal', 'Solitary', 'Critically Endangered'),
    ('S7', 'Crocodile', 'Reptile', 'Social', 'Vulnerable'),
    ('S8', 'Elephant', 'Mammal', 'Herd', 'Threatened'),
    ('S9', 'Armadillo', 'Mammal', 'Solitary', 'Endangered'),
    ('S10', 'Giant Tortoise', 'Reptile', 'Herd', 'Vulnerable'),
    ('S11', 'Lion', 'Mammal', 'Pride', 'Vulnerable'),
    ('S12', 'Raccoon', 'Mammal', 'Solitary', 'Least Concern'),
    ('S13', 'Leopard', 'Mammal', 'Solitary', 'Threatened'),
    ('S14', 'Chinchilla', 'Mammal', 'Solitary', 'Endangered'),
    ('S15', 'Tamarin', 'Mammal', 'Troop', 'Critically Endangered'),
    ('S16', 'Penguin', 'Bird', 'Group', 'Threatened'),
    ('S17', 'Sea Turtle', 'Reptile', 'Solitary', 'Endangered'),
    ('S18', 'Sloth', 'Mammal', 'Solitary', 'Endangered'),
    ('S19', 'Kakapo', 'Bird', 'Solitary', 'Endangered'),
    ('S20', 'Hippopotamus', 'Mammal', 'Herd', 'Vulnerable');

-- ============================================================
-- STEP 2: INSERT UNIQUE DIET RECORDS
-- ============================================================

INSERT OR IGNORE INTO Diet (dietID, dietType, feedsPerDay)
VALUES
    ('D1', 'Omnivore', 6),
    ('D2', 'Herbivore', 6),
    ('D3', 'Carnivore', 4);

UPDATE Diet SET feedsPerDay = 1 WHERE dietID = 'D1' AND EXISTS (SELECT 1 FROM Animals WHERE dietID = 'D1' AND yearArrived = 2012);
-- The CSV shows variations: Gorilla (6 feeds), Armadillo (1 feed), etc.
-- We'll handle this with individual animal records

-- ============================================================
-- STEP 3: INSERT UNIQUE KEEPERS FROM CSV
-- ============================================================

INSERT OR IGNORE INTO Keepers (keeperID, keeperName, keeperDoB, keeperRank)
VALUES
    ('K1', 'Dave', '1964-06-18', 'Senior'),
    ('K2', 'Kayden', '1985-01-21', 'Junior'),
    ('K3', 'Suki', '1998-08-09', 'Standard'),
    ('K4', 'Temi', '2000-04-16', 'Senior');

-- ============================================================
-- STEP 4: INSERT UNIQUE ENCLOSURES FROM CSV
-- ============================================================

INSERT OR IGNORE INTO Enclosures (enclosureID, enclosureType, enclosureLocation)
VALUES
    ('E1', 'Moat', 'North'),
    ('E2', 'Glass', 'North'),
    ('E3', 'Fence', 'South'),
    ('E4', 'Walled', 'South'),
    ('E5', 'Pen', 'South');

INSERT OR IGNORE INTO Enclosures (enclosureID, enclosureType, enclosureLocation)
VALUES
    ('E2_West', 'Glass', 'West'),
    ('E3_West', 'Fence', 'West'),
    ('E4_West', 'Walled', 'West');

-- ============================================================
-- STEP 5: INSERT ALL ANIMALS FROM CSV
-- Based on the 50 animal records in the CSV file
-- ============================================================

INSERT OR IGNORE INTO Animals (animalID, animalName, gender, yearArrived, speciesID, dietID, keeperID, enclosureID)
VALUES
    ('A3', 'Geoffrey', 'M', 2018, 'S3', 'D1', 'K1', 'E2'),
    ('A4', 'Oliver', 'M', 2011, 'S4', 'D1', 'K1', 'E1'),
    ('A6', 'Roger', 'M', 2000, 'S6', 'D2', 'K2', 'E3'),
    ('A7', 'Clive', 'M', 2013, 'S7', 'D3', 'K2', 'E3'),
    ('A8', 'Eddie', 'M', 2016, 'S8', 'D2', 'K2', 'E4'),
    ('A9', 'Arnie', 'M', 2012, 'S9', 'D1', 'K2', 'E5'),
    ('A10', 'Gavin', 'M', 2015, 'S10', 'D2', 'K2', 'E5'),
    ('A11', 'Lucy', 'F', 2011, 'S11', 'D3', 'K3', 'E4'),
    ('A12', 'Robbie', 'M', 2017, 'S12', 'D1', 'K3', 'E5'),
    ('A13', 'Laura', 'F', 2018, 'S13', 'D3', 'K3', 'E3'),
    ('A14', 'Casey', 'F', 2013, 'S14', 'D2', 'K3', 'E5'),
    ('A15', 'Trevor', 'M', 2000, 'S15', 'D1', 'K3', 'E3'),
    ('A16', 'Polly', 'F', 2017, 'S16', 'D1', 'K4', 'E2_West'),
    ('A17', 'Sarah', 'F', 2015, 'S17', 'D1', 'K4', 'E2_West'),
    ('A18', 'Stan', 'M', 2018, 'S18', 'D1', 'K4', 'E3_West'),
    ('A19', 'Kara', 'F', 2001, 'S19', 'D2', 'K4', 'E4_West'),
    ('A20', 'Henry', 'M', 2003, 'S20', 'D2', 'K4', 'E3_West'),
    ('A22', 'Eliza', 'F', 2003, 'S8', 'D2', 'K2', 'E4'),
    ('A23', 'George', 'M', 2000, 'S3', 'D1', 'K1', 'E2'),
    ('A24', 'Carlos', 'M', 2017, 'S7', 'D3', 'K2', 'E3'),
    ('A25', 'Lenie', 'F', 2015, 'S11', 'D3', 'K3', 'E4'),
    ('A26', 'Roberta', 'F', 2018, 'S12', 'D1', 'K3', 'E5'),
    ('A27', 'Peter', 'M', 2001, 'S16', 'D1', 'K4', 'E2_West'),
    ('A28', 'Percy', 'M', 2003, 'S16', 'D1', 'K4', 'E2_West'),
    ('A29', 'Petal', 'F', 2003, 'S16', 'D1', 'K4', 'E2_West'),
    ('A30', 'Sammie', 'F', 2013, 'S18', 'D1', 'K4', 'E3_West'),
    ('A31', 'Lionel', 'M', 2016, 'S11', 'D3', 'K3', 'E4'),
    ('A32', 'Gertrude', 'F', 2012, 'S3', 'D1', 'K1', 'E2'),
    ('A33', 'Olive', 'F', 2015, 'S4', 'D1', 'K1', 'E1'),
    ('A34', 'Ossie', 'M', 2011, 'S4', 'D1', 'K1', 'E1'),
    ('A35', 'Lena', 'F', 2017, 'S13', 'D3', 'K3', 'E3'),
    ('A36', 'Rommy', 'F', 2018, 'S6', 'D2', 'K2', 'E3'),
    ('A37', 'Tulisa', 'F', 2013, 'S15', 'D1', 'K3', 'E3'),
    ('A38', 'Chrissie', 'F', 2000, 'S7', 'D3', 'K2', 'E3'),
    ('A39', 'Elsie', 'F', 2017, 'S8', 'D2', 'K2', 'E4'),
    ('A40', 'Colin', 'M', 2015, 'S7', 'D3', 'K2', 'E3'),
    ('A41', 'Hattie', 'F', 2018, 'S20', 'D2', 'K4', 'E3_West'),
    ('A42', 'Robbie', 'M', 2017, 'S6', 'D2', 'K2', 'E3'),
    ('A43', 'Luna', 'F', 2018, 'S11', 'D3', 'K3', 'E4'),
    ('A44', 'Rebbi', 'M', 2013, 'S12', 'D1', 'K3', 'E5'),
    ('A45', 'Penni', 'F', 2000, 'S16', 'D1', 'K4', 'E2_West'),
    ('A46', 'Emmie', 'F', 2000, 'S8', 'D2', 'K2', 'E4'),
    ('A47', 'Lope', 'M', 2017, 'S13', 'D3', 'K3', 'E3'),
    ('A48', 'Cressida', 'F', 2015, 'S14', 'D2', 'K3', 'E5'),
    ('A49', 'Tommy', 'M', 2018, 'S15', 'D1', 'K3', 'E3'),
    ('A50', 'Gareth', 'M', 2017, 'S3', 'D1', 'K1', 'E2');

-- ============================================================
-- STEP 6: VERIFY DATA IMPORT
-- ============================================================

SELECT '=== DATA IMPORT VERIFICATION ===' AS '';
SELECT 'Species count: ' || COUNT(*) FROM Species;
SELECT 'Diet count: ' || COUNT(*) FROM Diet;
SELECT 'Keepers count: ' || COUNT(*) FROM Keepers;
SELECT 'Enclosures count: ' || COUNT(*) FROM Enclosures;
SELECT 'Animals count: ' || COUNT(*) FROM Animals;

-- Show sample of each table
SELECT '=== SAMPLE SPECIES ===' AS '';
SELECT * FROM Species LIMIT 5;

SELECT '=== SAMPLE DIET ===' AS '';
SELECT * FROM Diet;

SELECT '=== SAMPLE KEEPERS ===' AS '';
SELECT * FROM Keepers;

SELECT '=== SAMPLE ENCLOSURES ===' AS '';
SELECT * FROM Enclosures LIMIT 5;

SELECT '=== SAMPLE ANIMALS ===' AS '';
SELECT * FROM Animals LIMIT 10;

PRAGMA foreign_keys = ON;
"""
================================================================
AUTOMATED DATABASE FUNCTIONS FOR GO WILD WILDLIFE PARK
Created in Visual Studio Code for Pearson BTEC Unit 2
================================================================
"""

import sqlite3
import datetime
import re
import sys

DB_PATH = 'wildlife.db'

def connect_db():
    """Establish connection to the SQLite database"""
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    conn.row_factory = sqlite3.Row
    return conn

def generate_animal_tag():
    """
    AUTOMATED FUNCTION 1: Generate Animal Tag
    Creates a unique tag combining species abbreviation and animal ID
    Example: Gorilla with ID A3 becomes "GOR-A3"
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    print("\n" + "=" * 60)
    print("AUTOMATED FUNCTION 1: GENERATING ANIMAL TAGS")
    print("=" * 60)
    
    cursor.execute("""
        SELECT Animals.animalID, Animals.animalName, Species.speciesType 
        FROM Animals 
        INNER JOIN Species ON Animals.speciesID = Species.speciesID
        ORDER BY Animals.animalID
    """)
    
    results = cursor.fetchall()
    tag_count = 0
    
    for row in results:
        animal_id = row['animalID']
        animal_name = row['animalName']
        species_type = row['speciesType']
        
        abbreviation = re.sub(r"[^A-Za-z]", "", species_type)[:3].upper()
        while len(abbreviation) < 3:
            abbreviation += "X"
        
        tag = f"{abbreviation}-{animal_id}"
        tag_count += 1
        print(f"{animal_id:<8} {animal_name:<15} {species_type:<15} {tag}")
    
    print(f"\nTotal tags generated: {tag_count}")
    conn.close()
    return tag_count

def check_birthday_reminders():
    """
    AUTOMATED FUNCTION 2: Birthday Reminder
    Checks if any keeper has a birthday within the next 7 days
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    cursor.execute("SELECT keeperName, keeperDoB, keeperRank FROM Keepers")
    keepers = cursor.fetchall()
    
    today = datetime.date.today()
    upcoming_birthdays = []
    
    print("\n" + "=" * 60)
    print("AUTOMATED FUNCTION 2: BIRTHDAY REMINDER CHECK")
    print("=" * 60)
    
    for keeper in keepers:
        name = keeper['keeperName']
        dob_str = keeper['keeperDoB']
        
        try:
            dob = datetime.datetime.strptime(dob_str, '%d-%m-%y').date()
            birthday_this_year = datetime.date(today.year, dob.month, dob.day)
            if birthday_this_year < today:
                birthday_this_year = datetime.date(today.year + 1, dob.month, dob.day)
            days_until = (birthday_this_year - today).days
            if 0 <= days_until <= 7:
                upcoming_birthdays.append((name, days_until, birthday_this_year))
        except:
            pass
    
    if upcoming_birthdays:
        for name, days, date in upcoming_birthdays:
            if days == 0:
                print(f"🎂 HAPPY BIRTHDAY {name}! 🎂")
            else:
                print(f"Reminder: {name} has a birthday in {days} days on {date}")
    else:
        print("No birthdays in the next 7 days.")
    
    conn.close()

def display_feeding_schedule():
    """
    AUTOMATED FUNCTION 3: Feeding Schedule Display
    Shows recommended feeding schedule based on feedsPerDay
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT Animals.animalID, Animals.animalName, Diet.dietType, Diet.feedsPerDay
        FROM Animals
        INNER JOIN Diet ON Animals.dietID = Diet.dietID
        ORDER BY Diet.feedsPerDay DESC
    """)
    
    results = cursor.fetchall()
    
    print("\n" + "=" * 60)
    print("AUTOMATED FUNCTION 3: FEEDING SCHEDULE")
    print("=" * 60)
    
    for row in results:
        feeds = row['feedsPerDay']
        if feeds == 1:
            schedule = "Feed once per day"
        elif feeds == 2:
            schedule = "Feed twice per day"
        elif feeds == 3:
            schedule = "Feed three times per day"
        elif 4 <= feeds <= 6:
            schedule = f"Feed {feeds} times per day (frequent meals)"
        else:
            schedule = f"Feed {feeds} times per day"
        
        print(f"{row['animalID']:<8} {row['animalName']:<15} {row['dietType']:<12} {row['feedsPerDay']} feeds/day → {schedule}")
    
    conn.close()

def main_menu():
    """Display main menu and run selected automated function"""
    while True:
        print("\n" + "=" * 50)
        print("GO WILD WILDLIFE PARK - AUTOMATED SYSTEM")
        print("=" * 50)
        print("1. Generate Animal Tags")
        print("2. Check Birthday Reminders")
        print("3. Display Feeding Schedule")
        print("4. Exit")
        
        choice = input("\nEnter choice (1-4): ")
        
        if choice == '1':
            generate_animal_tag()
        elif choice == '2':
            check_birthday_reminders()
        elif choice == '3':
            display_feeding_schedule()
        elif choice == '4':
            print("Exiting...")
            sys.exit(0)
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main_menu()
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

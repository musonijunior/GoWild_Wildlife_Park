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

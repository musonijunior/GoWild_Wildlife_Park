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

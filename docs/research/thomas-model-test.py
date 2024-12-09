
# Test of the Thomas Model for predicting body composition changes over time.
# This script calculates changes in fat mass, fat-free mass, and total weight over a specified time period
# based on a caloric deficit and initial body composition parameters.

import math
from datetime import datetime

# Constants
CALORIES_PER_KG_FAT = 7700
CALORIES_PER_KG_LEAN = 1000
KG_TO_LBS = 2.20462
REE_CONSTANTS = {'male': (5.8, 0.9, 0.2), 'female': (5.7, 0.8, 0.3)}
DEFAULT_VALUES = {
    'sex': 'male',
    'age': 36,
    'height': 183,  # cm
    'weight': 99.8,  # kg
    'fat_mass': 27.55,  # kg
    'lean_mass': 72.25,  # kg
    'calorie_deficit': 1000  # kcal/day
}
DEFAULT_HISTORICAL_DATA = [
    ("11/27/2024", 101.9, 0.288),
    ("11/28/2024", 101.77, 0.286),
    ("11/29/2024", 102.01, 0.286),
    ("11/30/2024", 101.34, 0.284),
    ("12/01/2024", 101.42, 0.284),
    ("12/02/2024", 100.95, 0.284),
    ("12/03/2024", 101.05, 0.283),
    ("12/04/2024", 100.42, 0.282),
    ("12/05/2024", 100.97, 0.279),
    ("12/06/2024", 100.05, 0.280),
    ("12/07/2024", 100.44, 0.281),
    ("12/08/2024", 99.77, 0.276),
    ("12/09/2024", 99.92, 0.277)
]
INTERVALS = [30, 60, 90, 120, 150, 180]

# Input Functions
def get_user_input():
    """Get initial conditions from the user or use default values."""
    use_defaults = input("Would you like to use default values? (yes/no): ").strip().lower()
    if use_defaults in ["no", "n"]:
        return get_manual_inputs()
    return DEFAULT_VALUES

def get_basic_user_info():
    """Prompt the user for basic personal used in both calculations."""
    sex = input("Enter sex (male/female): ").strip().lower()
    if sex in ["m", "ma", "mal", "male", "man"]:
        sex = "male"
    else:
        sex = "female"
    height = float(input("Enter height in cm: "))

    dob = input("Enter date of birth (YYYY-MM-DD): ").strip()
    age = calculate_age(dob)
    
    return {'sex': sex, 'height': height, 'age': age}

def prompt_historical_data():
    """Prompt user for historical data or use defaults."""
    use_defaults = input("Would you like to use default historical data? (yes/no): ").strip().lower()
    if use_defaults in ["no", "n"]:
        return get_manual_historical_data()
    return DEFAULT_HISTORICAL_DATA

def get_manual_historical_data():
    """Get manual histrorical data from the user for date, weight, and body fat percentage."""
    print("Enter your historical data as 'Date (MM/DD/YYYY), Weight (lbs), Body Fat (decimal)'.")
    print("Example: 11/27/2024, 200, 0.18")
    print("Type 'done' when finished.")
    historical_data = []
    while True:
        entry = input("> ").strip()
        if entry.lower() in ["done", "d"]:
            break
        try:
            date, weight, body_fat = entry.split(",")
            historical_data.append((date.strip(), float(weight)/KG_TO_LBS, float(body_fat)))
        except ValueError:
            print("Invalid input. Please enter in the correct format: 'Date, Weight, Body Fat'.")
    return historical_data

def get_manual_inputs():
    """Collect manual inputs from the user."""

    sex, height, age = get_basic_user_info()

    weight = float(input("Enter weight in kg: "))
    body_fat_percentage = float(input("Enter body fat percentage (decimal): "))

    fat_mass, lean_mass = calculate_fat_and_lean_mass(weight, body_fat_percentage)
    calorie_deficit = float(input("Enter daily calorie deficit (kcal): "))

    return {
        'sex': sex,
        'age': age,
        'height': height,
        'weight': weight,
        'fat_mass': fat_mass,
        'lean_mass': lean_mass,
        'calorie_deficit': calorie_deficit
    }


# Calculation Functions
def calculate_thomas_and_estimate_deficit():
    """Calculate the Thomas Model and estimate the calorie deficit based on historical data."""
    user_info = get_basic_user_info()
    historical_data = prompt_historical_data()
    display_historical_summary(historical_data)
    calorie_deficit = estimate_calorie_deficit_from_historical_data(historical_data)

    print(f"\nEstimated Calorie Deficit: {calorie_deficit:.2f} kcal/day\n")
    initial_weight = historical_data[-1][1]
    initial_fat_percentage = historical_data[-1][2]
    initial_fat_mass, initial_lean_mass = calculate_fat_and_lean_mass(initial_weight, initial_fat_percentage)
    bmi = calculate_bmi(initial_weight, user_info['height'])
    bmr = calculate_bmr(user_info['sex'], user_info['height'], user_info['age'], initial_weight)
    display_bmi_and_bmr(bmi, bmr)

    results = calculate_thomas(
        user_info['sex'], initial_fat_mass, initial_lean_mass, calorie_deficit
    )
    display_results(results, {'weight': initial_weight, 'fat_mass': initial_fat_mass, 'lean_mass': initial_lean_mass})

def calculate_thomas(sex, fat_mass, lean_mass, calorie_deficit):
    """Perform the Thomas Model calculations."""
    constants = REE_CONSTANTS[sex.lower()]
    c_ree, k1, k2 = constants

    results = []
    for day in range(1, max(INTERVALS) + 1):
        fat_mass, lean_mass = update_masses(c_ree, k1, k2, fat_mass, lean_mass, calorie_deficit)
        if day in INTERVALS:
            results.append(prepare_result(day, fat_mass, lean_mass))
    return results


def update_masses(c_ree, k1, k2, fat_mass, lean_mass, calorie_deficit):
    """Update fat and lean masses based on energy balance."""
    ree = c_ree + k1 * lean_mass + k2 * fat_mass
    energy_expenditure = ree * 1.1
    energy_balance = calorie_deficit - energy_expenditure

    fat_loss = max(0, 0.9 * energy_balance / CALORIES_PER_KG_FAT)
    lean_loss = max(0, 0.1 * energy_balance / CALORIES_PER_KG_FAT)

    fat_mass = max(0, fat_mass - fat_loss)
    lean_mass = max(0, lean_mass - lean_loss)

    return fat_mass, lean_mass

def calculate_fat_and_lean_mass(weight, body_fat_percentage):
    """Calculate fat and lean mass based on weight and body fat percentage."""
    fat_mass = weight * body_fat_percentage
    lean_mass = weight - fat_mass
    return fat_mass, lean_mass

def estimate_calorie_deficit(initial_fat_mass, final_fat_mass, initial_lean_mass, final_lean_mass, days):
    """Estimate the calorie deficit required to achieve the desired fat and lean mass changes."""
    fat_loss = initial_fat_mass - final_fat_mass
    lean_loss = initial_lean_mass - final_lean_mass
    fat_energy_loss = fat_loss * CALORIES_PER_KG_FAT
    lean_energy_loss = lean_loss * CALORIES_PER_KG_LEAN

    total_energy_loss = fat_energy_loss + lean_energy_loss
    calorie_deficit = total_energy_loss / days
    return calorie_deficit

def estimate_calorie_deficit_from_historical_data(historical_data):
    """Estimate calorie deficit based on historical data."""
    # Verify that historical data is not empty and contains at least two entries 
    # each with three values for date, weight, and body fat.
    if not historical_data or len(historical_data) < 2:
        print("Insufficient historical data. Please provide at least two data points.")
        return None
    
    initial_weight = historical_data[0][1]
    initial_fat_percentage = historical_data[0][2]
    initial_fat_mass, initial_lean_mass = calculate_fat_and_lean_mass(initial_weight, initial_fat_percentage)

    final_weight = historical_data[-1][1]
    final_fat_percentage = historical_data[-1][2]
    final_fat_mass, final_lean_mass = calculate_fat_and_lean_mass(final_weight, final_fat_percentage)

    days = (datetime.strptime(historical_data[-1][0], "%m/%d/%Y") - 
            datetime.strptime(historical_data[0][0], "%m/%d/%Y")).days
    
    return estimate_calorie_deficit(initial_fat_mass, final_fat_mass, initial_lean_mass, final_lean_mass, days)

def calculate_age(dob):
    """Calculate age based on date of birth."""
    dob_date = datetime.strptime(dob, "%Y-%m-%d")
    today = datetime.today()
    age = today.year - dob_date.year - ((today.month, today.day) < (dob_date.month, dob_date.day))
    return age

def calculate_bmi(weight, height):
    """Calculate BMI based on weight (kg) and height (cm)."""
    return weight / ((height / 100) ** 2)

def calculate_bmr(sex, height, age, weight):
    """Calculate Basal Metabolic Rate (BMR) based on the Mifflin-St Jeor Equation."""
    s = - 161 # Constant for female
    if sex == "male":
        s = 5
    return 10 * weight + 6.25 * height - 5 * age + s

# Conversion Functions
def cm_to_feet_and_inches(cm):
    """Convert centimeters to feet and inches."""
    inches_total = cm / 2.54
    feet = int(inches_total // 12)
    inches = inches_total % 12
    return f"{feet} ft {inches:.1f} in"

# Formatting Functions
def prepare_result(day, fat_mass, lean_mass):
    """Prepare the result for a specific day."""
    weight = fat_mass + lean_mass
    return {
        'Day': day,
        'Weight (kg)': weight,
        'Weight (lbs)': weight * KG_TO_LBS,
        'Fat Mass (kg)': fat_mass,
        'Fat Mass (lbs)': fat_mass * KG_TO_LBS,
        'Lean Mass (kg)': lean_mass,
        'Lean Mass (lbs)': lean_mass * KG_TO_LBS
    }

def format_change(current, initial):
    """Format the change in values with percentage and arrow."""
    change = current - initial
    percent_change = (change / initial) * 100 if initial > 0 else 0
    arrow = "↑" if change > 0 else "↓"
    return f"{arrow} {abs(percent_change):.2f}%"


# Display Functions
def display_initial_conditions(values):
    """Display the initial conditions."""
    print("\n--- Initial Conditions ---")
    print(f"Sex: {values['sex'].capitalize()}")
    print(f"Age: {values['age']} years")
    print(f"Height: {values['height']:.1f} cm ({cm_to_feet_and_inches(values['height'])})")
    print(f"Weight: {values['weight']:.2f} kg ({values['weight'] * KG_TO_LBS:.2f} lbs)")
    print(f"Fat Mass: {values['fat_mass']:.2f} kg ({values['fat_mass'] * KG_TO_LBS:.2f} lbs)")
    print(f"Lean Mass: {values['lean_mass']:.2f} kg ({values['lean_mass'] * KG_TO_LBS:.2f} lbs)")
    print(f"Calorie Deficit: {values['calorie_deficit']} kcal/day")
    print(f"Intervals: {INTERVALS} days\n")


def display_results(results, initial_values):
    """Display the results at each interval."""
    print("--- Prediction Results ---")
    print("Assuming the same daily calorie deficit, the following changes are predicted:\n")

    for result in results:
        display_result_for_day(result, initial_values)

def display_result_for_day(result, initial_values):
    """Display results for a specific day."""
    day = result['Day']
    weight = result['Weight (kg)']
    fat_mass = result['Fat Mass (kg)']
    lean_mass = result['Lean Mass (kg)']

    weight_change = format_change(weight, initial_values['weight'])
    fat_mass_change = format_change(fat_mass, initial_values['fat_mass'])
    lean_mass_change = format_change(lean_mass, initial_values['lean_mass'])

    print(f"Day {day}:")
    print(f"  Weight: {weight:.2f} kg ({result['Weight (lbs)']:.2f} lbs) {weight_change}")
    print(f"  Fat Mass: {fat_mass:.2f} kg ({result['Fat Mass (lbs)']:.2f} lbs) {fat_mass_change}")
    print(f"  Lean Mass: {lean_mass:.2f} kg ({result['Lean Mass (lbs)']:.2f} lbs) {lean_mass_change}\n")

def display_historical_summary(historical_data):
    """Display a summary of historical data."""
    print("\n--- Historical Data Summary ---")
    print("Date       | Weight (kg)| Weight (lbs)| Body Fat (%)")
    print("-" * 40)
    for date, weight, body_fat in historical_data:
        print(f"{date} | {weight:.2f} | {weight*KG_TO_LBS:.2f} | {body_fat * 100:.2f}%")
    print("-" * 40)

def display_bmi_and_bmr(bmi, bmr):
    """Display BMI and BMR values."""
    print(f"\n--- Additional Information ---")
    print(f"BMI: {bmi:.2f}")
    print(f"BMR: {bmr:.2f} kcal/day\n")

# Main Functions

def thomas_model():
    """Main function to execute the Thomas Model."""
    user_values = get_user_input()
    display_initial_conditions(user_values)
    results = calculate_thomas(
        user_values['sex'], user_values['fat_mass'], user_values['lean_mass'], user_values['calorie_deficit']
    )
    display_results(results, user_values)

def run_test():
    use_calorie_deficit = input("Do you know your calorie deficit? (yes/no): ").strip().lower()
    if use_calorie_deficit in ["yes", "y"]:
        thomas_model()
    else:
        calculate_thomas_and_estimate_deficit()

# Run the Thomas Model
if __name__ == "__main__":
    run_test()

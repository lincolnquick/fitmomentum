
# Test of the Thomas Model for predicting body composition changes over time.
# This script calculates changes in fat mass, fat-free mass, and total weight over a specified time period
# based on a caloric deficit and initial body composition parameters.

import math

# Constants
CALORIES_PER_KG_FAT = 7700
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
INTERVALS = [30, 60, 90, 120, 150, 180]


def get_user_input():
    """Get initial conditions from the user or use default values."""
    use_defaults = input("Would you like to use default values? (yes/no): ").strip().lower()
    if use_defaults in ["no", "n"]:
        return get_manual_inputs()
    return DEFAULT_VALUES


def get_manual_inputs():
    """Collect manual inputs from the user."""
    return {
        'sex': input("Enter sex (male/female): ").strip().lower(),
        'age': int(input("Enter age in years: ")),
        'height': float(input("Enter height in cm: ")),
        'weight': float(input("Enter weight in kg: ")),
        'fat_mass': float(input("Enter fat mass in kg: ")),
        'lean_mass': float(input("Enter lean mass in kg: ")),
        'calorie_deficit': float(input("Enter daily calorie deficit (kcal): "))
    }


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


def prepare_result(day, fat_mass, lean_mass):
    """Prepare the result for a specific day."""
    weight = fat_mass + lean_mass
    return {
        'Day': day,
        'Weight (kg)': weight,
        'Weight (lbs)': weight * 2.20462,
        'Fat Mass (kg)': fat_mass,
        'Fat Mass (lbs)': fat_mass * 2.20462,
        'Lean Mass (kg)': lean_mass,
        'Lean Mass (lbs)': lean_mass * 2.20462
    }


def cm_to_feet_and_inches(cm):
    """Convert centimeters to feet and inches."""
    inches_total = cm / 2.54
    feet = int(inches_total // 12)
    inches = inches_total % 12
    return f"{feet} ft {inches:.1f} in"


def format_change(current, initial):
    """Format the change in values with percentage and arrow."""
    change = current - initial
    percent_change = (change / initial) * 100 if initial > 0 else 0
    arrow = "↑" if change > 0 else "↓"
    return f"{arrow} {abs(percent_change):.2f}%"


def display_initial_conditions(values):
    """Display the initial conditions."""
    print("\n--- Initial Conditions ---")
    print(f"Sex: {values['sex'].capitalize()}")
    print(f"Age: {values['age']} years")
    print(f"Height: {values['height']:.1f} cm ({cm_to_feet_and_inches(values['height'])})")
    print(f"Weight: {values['weight']:.2f} kg ({values['weight'] * 2.20462:.2f} lbs)")
    print(f"Fat Mass: {values['fat_mass']:.2f} kg ({values['fat_mass'] * 2.20462:.2f} lbs)")
    print(f"Lean Mass: {values['lean_mass']:.2f} kg ({values['lean_mass'] * 2.20462:.2f} lbs)")
    print(f"Calorie Deficit: {values['calorie_deficit']} kcal/day")
    print(f"Intervals: {INTERVALS} days\n")


def display_results(results, initial_values):
    """Display the results at each interval."""
    print("--- Results ---")
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


def thomas_model():
    """Main function to execute the Thomas Model."""
    user_values = get_user_input()
    display_initial_conditions(user_values)
    results = calculate_thomas(
        user_values['sex'], user_values['fat_mass'], user_values['lean_mass'], user_values['calorie_deficit']
    )
    display_results(results, user_values)


# Run the refactored Thomas Model
thomas_model()

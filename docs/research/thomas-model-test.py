
# Test of the Thomas Model for predicting body composition changes over time.
# This script calculates changes in fat mass, fat-free mass, and total weight over a specified time period
# based on a caloric deficit and initial body composition parameters.

# Conversion factor for kg to lbs
kg_to_lbs = 2.20462

# Define the equations for Lean Mass (formerly Fat-Free Mass) for males and females as per the Thomas Model
def thomas_model_lean_mass_male(F, A0, t, H):
    return (-71.7 + 3.6 * F
            - 0.04 * (A0 + t / 365)
            + 0.7 * H
            - 0.002 * F * (A0 + t / 365)
            - 0.01 * F * H
            + 0.00003 * F**2 * (A0 + t / 365)
            - 0.07 * F**2
            + 0.0006 * F**3
            - 0.000002 * F**4
            + 0.0003 * F**2 * H
            - 0.000002 * F**3 * H)

def thomas_model_lean_mass_female(F, A0, t, H):
    return (-72.1 + 2.5 * F
            - 0.04 * (A0 + t / 365)
            + 0.7 * H
            - 0.002 * F * (A0 + t / 365)
            - 0.01 * F * H
            - 0.04 * F**2
            + 0.0003 * F**2 * (A0 + t / 365)
            + 0.0000004 * F**4
            + 0.0002 * F**3
            + 0.0003 * F**2 * H
            - 0.000002 * F**3 * H)

# Calculate Fat Mass (FM) over time based on caloric deficit
def calculate_fat_mass(F0, deficit, time):
    kcal_per_kg_fat = 7700  # Energy content of fat (1 kg = 7700 kcal)
    fat_loss = (deficit * time) / kcal_per_kg_fat  # in kg
    return max(0, F0 - fat_loss)  # Ensure fat mass cannot be negative

# Prompt for user input
def get_user_input():
    user_choice = input("Would you like to enter your own initial conditions? (yes/no): ").strip().lower()
    if user_choice == "yes":
        sex = input("Enter sex (Male/Female): ").strip().capitalize()
        age = int(input("Enter age (in years): "))
        height = float(input("Enter height (in cm): "))
        starting_weight = float(input("Enter starting weight (in kg): "))
        initial_fat_mass = float(input("Enter initial fat mass (in kg): "))
        caloric_deficit_per_day = int(input("Enter caloric deficit per day (in kcal): "))
        return {
            "sex": sex,
            "age": age,
            "height": height,
            "starting_weight": starting_weight,
            "initial_fat_mass": initial_fat_mass,
            "caloric_deficit_per_day": caloric_deficit_per_day
        }
    else:
        # Default values
        return {
            "sex": "Male",
            "age": 36,
            "height": 183,
            "starting_weight": 100,
            "initial_fat_mass": 28,
            "caloric_deficit_per_day": 750
        }

# Perform calculations
def calculate_results(params, times):
    sex = params["sex"]
    age = params["age"]
    height = params["height"]
    starting_weight = params["starting_weight"]
    initial_fat_mass = params["initial_fat_mass"]
    caloric_deficit_per_day = params["caloric_deficit_per_day"]
    
    initial_lean_mass = starting_weight - initial_fat_mass

    results = {}
    for t in times:
        fat_mass_t = calculate_fat_mass(initial_fat_mass, caloric_deficit_per_day, t)
        if sex == "Male":
            lean_mass_t = thomas_model_lean_mass_male(fat_mass_t, age, t, height)
        elif sex == "Female":
            lean_mass_t = thomas_model_lean_mass_female(fat_mass_t, age, t, height)
        else:
            raise ValueError("Invalid sex entered. Please use 'Male' or 'Female'.")
        weight_t = fat_mass_t + lean_mass_t

        # Calculate percentage changes
        fat_mass_change = ((fat_mass_t - initial_fat_mass) / initial_fat_mass) * 100
        lean_mass_change = ((lean_mass_t - initial_lean_mass) / initial_lean_mass) * 100
        weight_change = ((weight_t - starting_weight) / starting_weight) * 100

        results[t] = {
            "Fat Mass (kg)": (fat_mass_t, fat_mass_change),
            "Lean Mass (kg)": (lean_mass_t, lean_mass_change),
            "Total Weight (kg)": (weight_t, weight_change),
            "Fat Mass (lbs)": (fat_mass_t * kg_to_lbs, fat_mass_change),
            "Lean Mass (lbs)": (lean_mass_t * kg_to_lbs, lean_mass_change),
            "Total Weight (lbs)": (weight_t * kg_to_lbs, weight_change),
        }
    return initial_lean_mass, results

if __name__ == "__main__":
    # Get initial conditions
    user_params = get_user_input()
    times = [30, 60, 90, 120, 150, 180]  # Time periods in days

    # Perform calculations
    initial_lean_mass, results = calculate_results(user_params, times)

    # Display initial conditions
    print("\nInitial Parameters:")
    print(f"Sex: {user_params['sex']}")
    print(f"Age: {user_params['age']} years")
    print(f"Height: {user_params['height']} cm ({user_params['height'] * 0.393701:.2f} inches)")
    print(f"Starting Weight: {user_params['starting_weight']:.2f} kg ({user_params['starting_weight'] * kg_to_lbs:.2f} lbs)")
    print(f"Initial Fat Mass: {user_params['initial_fat_mass']:.2f} kg ({user_params['initial_fat_mass'] * kg_to_lbs:.2f} lbs)")
    print(f"Initial Lean Mass: {initial_lean_mass:.2f} kg ({initial_lean_mass * kg_to_lbs:.2f} lbs)")
    print(f"Caloric Deficit Per Day: {user_params['caloric_deficit_per_day']} kcal\n")

    # Display results
    print("Results:")
    for t, values in results.items():
        print(f"--- After {t} Days ---")
        for key, (value, change) in values.items():
            change_symbol = "↑" if change > 0 else "↓"
            print(f"{key}: {value:.2f} ({change_symbol}{abs(change):.2f}%)")
        print()

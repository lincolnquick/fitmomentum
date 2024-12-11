
import numpy as np
import matplotlib.pyplot as plt
import mplcursors

# Constants
CF = 1020  # Energy density of FFM (kcal/kg)
CL = 9500  # Energy density of FM (kcal/kg)
S_LOSS = 2 / 3
S_GAIN = 0.56
BETA_LOSS = 0.075
BETA_GAIN = 0.086
RMR = {"male": {"c": 293, "p": 0.433, "y": 5.92}, 
       "female": {"c": 248, "p": 0.4356, "y": 5.09}} # RMR constants
BASELINE_SPA_FACTOR = 0.326 # SPA(0) = 0.326 * E(0) or baseline energy
CONVERSION_FACTOR = 2.20462  # lbs to kg conversion factor
BASELINE_PA = 50  # Baseline physical activity level, small 50 kcal/day
ESSENTIAL_FAT_MASS = {"male":5, "female":12}  # Essential fat mass in kg}
ESSENTIAL_LEAN_MASS = {"male": 18, "female": 18} # Smallest healthy lean mass in kg

# Functions
def calculate_rmr(weight, age, sex):
    """
    Calculate the Resting Metabolic Rate (RMR) based on weight, age, and sex using
    the Livingston-Kohlstadt formula.
    
    Parameters:
        weight (float): Weight in kilograms.
        age (int): Age in years.
        sex (str): 'male' or 'female'.
    
    Returns:
        float: Resting Metabolic Rate (RMR) in kcal/day.
    """
    c, p, y = RMR[sex].values()
    rmr = c * (max(weight, 0) ** p) - y * age
    return max(rmr, 0)

def calculate_pa(weight, baseline_pa, baseline_weight):
    """
    Calculate Physical Activity (PA) based on current weight and baseline values.
    PA = m * weight, where m = baseline_pa / baseline_weight.
    
    Parameters:
        weight (float): Current weight in kilograms.
        baseline_pa (float): Baseline physical activity in kcal/day.
        baseline_weight (float): Baseline weight in kilograms.
    
    Returns:
        float: Physical Activity (PA) in kcal/day.
    """
    m = baseline_pa / baseline_weight
    return m * weight

def calculate_dit(energy_intake, weight_change_phase="loss"):
    """
    Calculate Dietary-Induced Thermogenesis (DIT) based on energy intake and weight change phase.
    DIT = beta * energy_intake, where beta = BETA_LOSS if weight_change_phase == "loss" else BETA_GAIN.

    Parameters:
        energy_intake (float): Energy intake in kcal/day.
        weight_change_phase (str): 'loss' or 'gain'.

    Returns:
        float: Dietary-Induced Thermogenesis (DIT) in kcal/day.
    """
    beta = BETA_LOSS if weight_change_phase == "loss" else BETA_GAIN
    return beta * energy_intake

def calculate_spa(rmr, pa, dit, weight_change_phase, constant_c):
    """
    Calculate Spontaneous Physical Activity (SPA) based on RMR, PA, DIT, weight change phase, and a constant.
    SPA = (s / (1 - s)) * (DIT + PA + RMR) + c, where s = S_LOSS if weight_change_phase == "loss" else S_GAIN,
    and c is a constant calculated based on baseline energy.
    SPA cannot be lower than 0.

    Parameters:
        rmr (float): Resting Metabolic Rate (RMR) in kcal/day.
        pa (float): Physical Activity (PA) in kcal/day.
        dit (float): Dietary-Induced Thermogenesis (DIT) in kcal/day.
        weight_change_phase (str): 'loss' or 'gain'.
        constant_c (float): Constant calculated based on baseline energy.

    Returns:
        float: Spontaneous Physical Activity (SPA) in kcal/day.
    """
    s = S_LOSS if weight_change_phase == "loss" else S_GAIN
    spa = (s / (1 - s)) * (dit + pa + rmr) + constant_c
    return max(spa, 0)

def calculate_constant_c(baseline_energy, rmr, pa, dit, weight_change_phase):
    """
    Calculate a constant (c) based on baseline energy, RMR, PA, DIT, and weight change phase.
    c = BASELINE_SPA_FACTOR * baseline_energy - (s / (1 - s)) * (DIT + PA + RMR), where
    s = S_LOSS if weight_change_phase == "loss" else S_GAIN.
    This assumes that baseline SPA is 32.6% of baseline energy.

    Parameters:
        baseline_energy (float): Baseline energy requirements in kcal/day.
        rmr (float): Resting Metabolic Rate (RMR) in kcal/day.
        pa (float): Physical Activity (PA) in kcal/day.
        dit (float): Dietary-Induced Thermogenesis (DIT) in kcal/day.
        weight_change_phase (str): 'loss' or 'gain'.
    """
    s = S_LOSS if weight_change_phase == "loss" else S_GAIN
    constant_c = BASELINE_SPA_FACTOR * baseline_energy - (s / (1 - s)) * (dit + pa + rmr)
    return constant_c

def calculate_baseline_pa(baseline_energy, dit0, spa0, rmr0):
    """
    Calculate baseline physical activity (PA) based on baseline energy, DIT, SPA, and RMR.
    PA0 = baseline_energy - DIT0 - SPA0 - RMR0.
    Baseline PA is estimated after calculating baseline values for DIT and RMR, as well as
    estimating SPA as 32.6% of baseline energy.
    This assumes that baseline energy (TEE0) is already calculated.

    Parameters:
        baseline_energy (float): Baseline energy requirements in kcal/day.
        dit0 (float): Baseline Dietary-Induced Thermogenesis (DIT) in kcal/day.
        spa0 (float): Baseline Spontaneous Physical Activity (SPA) in kcal/day.
        rmr0 (float): Baseline Resting Metabolic Rate (RMR) in kcal/day.
    """
    pa0 = baseline_energy - dit0 - spa0 - rmr0
    return max(pa0, 0)


def calculate_ffm(fat_mass, age, t, height, sex):
    """
    Calculate Fat-Free Mass (FFM), also known as lean mass, based on fat mass, age, time, height, and sex, 
    according to the differential equations proposed by Thomas et al. (2011).
    
    Parameters:
        fat_mass (float): Fat mass in kilograms.
        age (int): Age in years.
        t (int): Time in days.
        height (float): Height in cent
        sex (str): "male" or "female"

    Returns:
        float: Fat-Free Mass (FFM) in kilograms.
    """
    if sex == "male":
        ffm = (
            -71.7
            + 3.6 * fat_mass
            - 0.04 * (age + t / 365)
            + 0.7 * height
            - 0.002 * fat_mass * (age + t / 365)
            - 0.01 * fat_mass * height
            + 0.00003 * fat_mass**2 * (age + t / 365)
            - 0.07 * fat_mass**2
            + 0.0006 * fat_mass**3
            - 0.000002 * fat_mass**4
            + 0.0003 * fat_mass**2 * height
            - 0.000002 * fat_mass**3 * height
        )
    elif sex == "female":
        ffm = (
            -72.1
            + 2.5 * fat_mass
            - 0.04 * (age + t / 365)
            + 0.7 * height
            - 0.002 * (age + t / 365)
            - 0.01 * fat_mass * height
            - 0.04 * fat_mass**2 * (age + t / 365)
            + 0.0000004 * fat_mass**4
            + 0.0002 * fat_mass**3
            + 0.0003 * fat_mass**2 * height
            - 0.000002 * fat_mass**3 * height
        )
    else:
        raise ValueError("Sex must be 'male' or 'female'.")
    return max(ffm, 0)

def calculate_baseline_fat_mass(weight_kg, age, height_cm, sex):
    """
    Calculate baseline fat mass based on weight, age, height, and sex using the linear regression analysis 
    performed by Thomas et al. (2011).

    This calculation is used when the user enters a weight and does not provide a fat mass or 
    body fat percentage.

    Parameters:
        weight_kg (float): Weight in kilograms.
        age (int): Age in years.
        height_cm (float): Height in centimeters.
        sex (str): "male" or "female"

    Returns:
        float: Baseline fat mass in kilograms.
    """
    if sex == "male":
        return max(24.96493 + 0.064761 * age - 0.28889 * height_cm + 0.55342 * weight_kg, 0)
    elif sex == "female":
        return max(18.19812 + 0.043109 * age - 0.23014 * height_cm + 0.641413 * weight_kg, 0)
    else:
        raise ValueError("Sex must be 'male' or 'female'.")

def calculate_baseline_energy_requirements(weight_kg, age, height_cm, sex):
    """
    Calculate baseline energy requirements based on weight, age, height, and sex using the linear regression analysis
    performed by Thomas et al. (2011).
    
    This is used when the user does not provide an total energy expenditure (TEE) value 
    (also referred to as baseline energy or maintenance calories).

    Parameters:
        weight_kg (float): Weight in kilograms.
        age (int): Age in years.
        height_cm (float): Height in centimeters.
        sex (str): "male" or "female"

    Returns:   
        float: Baseline energy requirements in kcal/day.
    """
    if sex == "male":
        return max(892.721 - 16.7 * age + 1.29 * height_cm + 42.9 * weight_kg - 0.11435 * weight_kg**2, 0)
    elif sex == "female":
        return max(430.29 - 12.86 * age + 12.19 * height_cm + 4.066 * weight_kg + 0.043 * weight_kg**2, 0)
    else:
        raise ValueError("Sex must be 'male' or 'female'.")

def calculate_ffm_fm_changes(delta_e, fat_mass, age, t, height, sex):
    """
    Calculate the changes in fat mass (F) and fat-free mass (FFM) based on the energy balance equation
    proposed by Thomas et al. (2011).
    
    Parameters:
        delta_e (float): Energy balance (energy intake - total energy expenditure) in kcal/day.
        fat_mass (float): Fat mass in kilograms.
        age (int): Age in years. (not currently used in this implementation)
        t (int): Time in days. (not currently used in this implementation)
        height (float): Height in centimeters. (not currently used in this implementation)
        sex (str): "male" or "female" (not currently used in this implementation)
        
        Returns:
        tuple: A tuple containing the rate of change in fat mass (dF_dt) and fat-free mass (dFFM_dt) in kg/day.
        """
    partial_ffm_f = 1 / (fat_mass + 1)  # Avoid division by zero
    dF_dt = (delta_e - CF * partial_ffm_f) / (CL + CF * partial_ffm_f)
    dFFM_dt = partial_ffm_f * dF_dt
    return dF_dt, dFFM_dt

def run_simulation(sex, age, weight_kg, height_cm, energy_intake, duration_days):
    """
    Run a simulation of weight loss or gain over a specified duration based on the Thomas et al. (2011) model.
    
    Parameters:
        sex (str): "male" or "female"
        age (int): Age in years
        weight_kg (float): Weight in kilograms
        height_cm (float): Height in centimeters
        energy_intake (float): Energy intake in kcal/day
        duration_days (int): Duration of the simulation in days

    Returns:
        list: A list of dictionaries containing the results of the simulation for each day. 
        [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
        
        """

    # Initialize variables
    baseline_energy = calculate_baseline_energy_requirements(weight_kg, age, height_cm, sex)
    weight_change_phase = "loss" if energy_intake < baseline_energy else "gain"

    fat_mass = calculate_baseline_fat_mass(weight_kg, age, height_cm, sex)
    ffm = weight_kg - fat_mass

    rmr = calculate_rmr(weight_kg, age, sex)
    dit = calculate_dit(energy_intake, weight_change_phase)
    
    spa0 = BASELINE_SPA_FACTOR * baseline_energy
    pa = calculate_baseline_pa(baseline_energy, dit, spa0, rmr) 
    spa = calculate_spa(rmr, pa, dit, weight_change_phase, 0)  # constant_c is calculated later
    constant_c = calculate_constant_c(baseline_energy, rmr, pa, dit, weight_change_phase)
    spa = calculate_spa(rmr, pa, dit, weight_change_phase, constant_c) # Recalculate SPA with constant_c
    
    
    tee = rmr + dit + spa + pa

    results = []
    results.append({
            "day": 0,
            "weight": weight_kg,
            "fat_mass": fat_mass,
            "lean_mass": ffm,
            "tee": tee,
            "rmr": rmr,
            "dit": dit,
            "spa": spa,
            "pa": pa
        })

    results = iterate_simulation(
        sex, age, weight_kg, height_cm, energy_intake, duration_days, rmr, dit, spa, pa, constant_c, fat_mass, ffm, results
    )

    return results

def iterate_simulation(sex, age, weight_kg, height_cm, energy_intake, duration_days, rmr, dit, spa, pa, c, fat_mass, ffm, results):
    """
    Iterate the simulation over the specified duration, updating the weight, fat mass, lean mass, and energy expenditure
    for each day.
    
    Parameters:
        sex (str): "male" or "female"
        age (int): Age in years
        weight_kg (float): Weight in kilograms
        height_cm (float): Height in centimeters
        energy_intake (float): Energy intake in kcal/day
        duration_days (int): Duration of the simulation in days
        rmr (float): Resting Metabolic Rate (RMR) in kcal/day
        dit (float): Dietary-Induced Thermogenesis (DIT) in kcal/day
        spa (float): Spontaneous Physical Activity (SPA) in kcal/day
        pa (float): Physical Activity (PA) in kcal/day
        c (float): Constant calculated based on baseline energy
        fat_mass (float): Fat mass in kilograms
        ffm (float): Fat-Free Mass (FFM) or lean mass in kilograms
        results (list): A list of dictionaries containing the results of the simulation for each day.
        
        Returns:
        list: A list of dictionaries containing the updated results of the simulation for each day.
        [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
        """
    for day in range(1, duration_days + 1):
        
        tee = rmr + dit + spa + pa
        delta_energy = energy_intake - tee
        weight_change_phase = "loss" if delta_energy < 0 else "gain"

        # Calculate changes in F and FFM
        dF_dt, dFFM_dt = calculate_ffm_fm_changes(delta_energy, fat_mass, age, day, height_cm, sex)
        fat_mass += dF_dt
        ffm += dFFM_dt

        # Check if weight loss is within healthy limits, terminate simulation if not.
        if fat_mass < ESSENTIAL_FAT_MASS[sex]:
            fat_mass = ESSENTIAL_FAT_MASS[sex]
            print(f"Warning: Fat mass is below essential fat mass on day {day}. Simulation ended early.")
            break
        if ffm < ESSENTIAL_LEAN_MASS[sex]:
            ffm = ESSENTIAL_LEAN_MASS[sex]
            print(f"Warning: Lean mass is below healthy limit on day {day}. Simulation ended early.")
            break

        # Update dependent variables
        weight_kg = fat_mass + ffm
        rmr = calculate_rmr(weight_kg, age, sex)
        dit = calculate_dit(energy_intake, weight_change_phase)
        pa = calculate_pa(weight_kg, results[0]["pa"], results[0]["weight"])
        spa = calculate_spa(rmr, pa, dit, weight_change_phase, c)
        tee = rmr + dit + pa + spa


        # Store results
        results.append({
            "day": day,
            "weight": weight_kg,
            "fat_mass": fat_mass,
            "lean_mass": ffm,
            "tee": tee,
            "rmr": rmr,
            "dit": dit,
            "spa": spa,
            "pa": pa
        })
    return results


# Plotting Functions
def plot_weight_loss(results):
    """
    Plot the weight, fat mass, and lean mass over time based on the simulation results.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]


    """
    days = [res['day'] for res in results]
    weights = [res['weight'] * CONVERSION_FACTOR for res in results]
    fat_mass = [res['fat_mass'] * CONVERSION_FACTOR for res in results]
    lean_mass = [res['lean_mass'] * CONVERSION_FACTOR for res in results]

    plt.figure(figsize=(10, 6))
    weight_line, = plt.plot(days, weights, label='Total Weight (lbs)', linewidth=2)
    fat_mass_line, = plt.plot(days, fat_mass, label='Fat Mass (lbs)', linewidth=2, linestyle='--')
    lean_mass_line, = plt.plot(days, lean_mass, label='Lean Mass (lbs)', linewidth=2, linestyle=':')
    plt.title('Weight, Fat Mass, and Lean Mass Over Time', fontsize=16)
    plt.xlabel('Days', fontsize=14)
    plt.ylabel('Weight (lbs)', fontsize=14)
    plt.legend()
    plt.grid(True)
    
    # Add interactive hover
    cursor = mplcursors.cursor([weight_line, fat_mass_line, lean_mass_line], hover=True)
    cursor.connect(
        "add",
        lambda sel: sel.annotation.set_text(
            f"Day: {days[int(sel.target[0])]}, Value: {sel.target[1]:.2f}"
        )
    )
    
    plt.show()

def plot_energy_expenditure(results):
    """
    Plot the components of energy expenditure (TEE, RMR, DIT, SPA, PA) over time based on the simulation results.
    
    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
        
    """
    days = [res['day'] for res in results]
    tee = [res['tee'] for res in results]
    rmr = [res['rmr'] for res in results]
    dit = [res['dit'] for res in results]
    spa = [res['spa'] for res in results]
    pa = [res['pa'] for res in results]

    plt.figure(figsize=(10, 6))
    tee_line, = plt.plot(days, tee, label='Total Energy Expenditure (TEE)', linewidth=2)
    rmr_line, = plt.plot(days, rmr, label='Resting Metabolic Rate (RMR)', linewidth=2, linestyle='--')
    dit_line, = plt.plot(days, dit, label='Dietary-Induced Thermogenesis (DIT)', linewidth=2, linestyle=':')
    spa_line, = plt.plot(days, spa, label='Spontaneous Physical Activity (SPA)', linewidth=2, linestyle='-.')
    pa_line, = plt.plot(days, pa, label='Physical Activity (PA)', linewidth=2, linestyle=':')
    plt.title('Energy Expenditure Components Over Time', fontsize=16)
    plt.xlabel('Days', fontsize=14)
    plt.ylabel('Energy (kcal/day)', fontsize=14)
    plt.legend()
    plt.grid(True)
    
    # Add interactive hover
    cursor = mplcursors.cursor([tee_line, rmr_line, dit_line, spa_line, pa_line], hover=True)
    cursor.connect(
        "add",
        lambda sel: sel.annotation.set_text(
            f"Day: {days[int(sel.target[0])]}, Value: {sel.target[1]:.2f}"
        )
    )
    
    plt.show()



def print_results(results):
    """
    
    Print the results of the simulation in tabular format.
    
    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
        
    """
    print("Day\tWeight(lb)\tBody Fat (%)\tFat Mass(lb)\tLean Mass(lb)\tTEE(kcal)\tRMR(kcal)\tDIT(kcal)\tSPA(kcal)\tPA(kcal)")
    for res in results:
        print(f"{res['day']}\t{res['weight']*CONVERSION_FACTOR:.2f}\t\t{res['fat_mass']/res['weight']:.2f}%\t\t{res['fat_mass']*CONVERSION_FACTOR:.2f}\t\t{res['lean_mass']*CONVERSION_FACTOR:.2f}\t\t{res['tee']:.2f}\t\t{res['rmr']:.2f}\t\t{res['dit']:.2f}\t\t{res['spa']:.2f}\t\t{res['pa']:.2f}")

def get_user_input():
    """
    Get user input for running the simulation.

    Returns:
        tuple: A tuple containing the user input values (sex, age, weight, height, energy_intake, duration).
    """
    sex = input("Enter sex (male/female): ").strip().lower()
    age = int(input("Enter age (years): "))
    weight_lbs = float(input("Enter weight (lbs): "))
    height_in = float(input("Enter height (in): "))
    energy_intake = float(input("Enter energy intake (kcal/day): "))
    duration = int(input("Enter duration (days): "))

    weight = weight_lbs / CONVERSION_FACTOR
    height = height_in * 2.54
    return sex, age, weight, height, energy_intake, duration

if __name__ == "__main__":
    """
    Main function to run the simulation based on user input and display the results.
    """
    # Get user input
    sex, age, weight, height, energy_intake, duration = get_user_input()

    # Run simulation
    results = run_simulation(sex, age, weight, height, energy_intake, duration)

    # Output results
    print_results(results)

    # Plot results
    plot_weight_loss(results)
    plot_energy_expenditure(results)

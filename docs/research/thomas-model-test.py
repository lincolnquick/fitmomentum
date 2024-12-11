
import numpy as np

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
ESSENTIAL_LEAN_MASS = {"male": 50, "female": 45} # Smallest healthy lean mass in kg

# Functions
def calculate_rmr(weight, age, sex):
    c, p, y = RMR[sex].values()
    rmr = c * (max(weight, 0) ** p) - y * age
    return max(rmr, 0)

def calculate_pa(weight, baseline_pa, baseline_weight):
    m = baseline_pa / baseline_weight
    return m * weight

def calculate_dit(energy_intake, weight_change_phase="loss"):
    beta = BETA_LOSS if weight_change_phase == "loss" else BETA_GAIN
    return beta * energy_intake

def calculate_spa(rmr, pa, dit, weight_change_phase, constant_c):
    s = S_LOSS if weight_change_phase == "loss" else S_GAIN
    spa = (s / (1 - s)) * (dit + pa + rmr) + constant_c
    return max(spa, 0)

def calculate_constant_c(baseline_energy, rmr, pa, dit, weight_change_phase):
    s = S_LOSS if weight_change_phase == "loss" else S_GAIN
    constant_c = BASELINE_SPA_FACTOR * baseline_energy - (s / (1 - s)) * (dit + pa + rmr)
    return constant_c

def calculate_ffm(fat_mass, age, t, height, sex):
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
    if sex == "male":
        return max(24.96493 + 0.064761 * age - 0.28889 * height_cm + 0.55342 * weight_kg, 0)
    elif sex == "female":
        return max(18.19812 + 0.043109 * age - 0.23014 * height_cm + 0.641413 * weight_kg, 0)
    else:
        raise ValueError("Sex must be 'male' or 'female'.")

def calculate_baseline_energy_requirements(weight_kg, age, height_cm, sex):
    if sex == "male":
        return max(892.721 - 16.7 * age + 1.29 * height_cm + 42.9 * weight_kg - 0.11435 * weight_kg**2, 0)
    elif sex == "female":
        return max(430.29 - 12.86 * age + 12.19 * height_cm + 4.066 * weight_kg + 0.043 * weight_kg**2, 0)
    else:
        raise ValueError("Sex must be 'male' or 'female'.")

def calculate_ffm_fm_changes(delta_e, fat_mass, age, t, height, sex):
    partial_ffm_f = 1 / (fat_mass + 1)  # Avoid division by zero
    dF_dt = (delta_e - CF * partial_ffm_f) / (CL + CF * partial_ffm_f)
    dFFM_dt = partial_ffm_f * dF_dt
    return dF_dt, dFFM_dt

def run_simulation(sex, age, weight_kg, height_cm, energy_intake, duration_days):

    # Initialize variables
    baseline_energy = calculate_baseline_energy_requirements(weight_kg, age, height_cm, sex)
    weight_change_phase = "loss" if energy_intake < baseline_energy else "gain"

    fat_mass = calculate_baseline_fat_mass(weight_kg, age, height_cm, sex)
    ffm = weight_kg - fat_mass

    rmr = calculate_rmr(weight_kg, age, sex)
    dit = calculate_dit(energy_intake, weight_change_phase)
    pa = calculate_pa(weight_kg, BASELINE_PA, weight_kg)  # Baseline PA calculation
    
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
        spa = calculate_spa(rmr, pa, dit, weight_change_phase, c)
        pa = calculate_pa(weight_kg, BASELINE_PA, results[0]["weight"])
        tee = rmr + dit + spa + pa


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


def print_results(results):
    print("Day\tWeight(lb)\tBody Fat (%)\tFat Mass(lb)\tLean Mass(lb)\tTEE(kcal)\tRMR(kcal)\tDIT(kcal)\tSPA(kcal)\tPA(kcal)")
    for res in results:
        print(f"{res['day']}\t{res['weight']*CONVERSION_FACTOR:.2f}\t\t{res['fat_mass']/res['weight']:.2f}%\t\t{res['fat_mass']*CONVERSION_FACTOR:.2f}\t\t{res['lean_mass']*CONVERSION_FACTOR:.2f}\t\t{res['tee']:.2f}\t\t{res['rmr']:.2f}\t\t{res['dit']:.2f}\t\t{res['spa']:.2f}\t\t{res['pa']:.2f}")

# User Input
sex = input("Enter sex (male/female): ").strip().lower()
age = int(input("Enter age (years): "))
weight_lbs = float(input("Enter weight (lbs): "))
height_in = float(input("Enter height (in): "))
energy_intake = float(input("Enter energy intake (kcal/day): "))
duration = int(input("Enter duration (days): "))

weight = weight_lbs / CONVERSION_FACTOR
height = height_in * 2.54

# Run simulation
results = run_simulation(sex, age, weight, height, energy_intake, duration)

# Output results
print_results(results)

"""


References: 
Hall, K., Sacks, G., Chandramohan, D., Chow, C. C., Wang, Y. C., Gortmaker, S. L., Swinburn, B. A., National Institute of Diabetes and Digestive and Kidney Diseases (NIDDK), National Institutes of Health (NIH), WHO Collaborating Centre for Obesity Prevention, Deakin University, Mailman School of Public Health, Columbia University, & Department of Society, Human Development and Health, Harvard School of Public Health, Harvard University. (2011). Quantification of the effect of energy imbalance on bodyweight. In Lancet (Vol. 9793). https://doi.org/10.1016/S0140-6736(11)60812-X
Hall, K., Sacks, G., Chandramohan, D., & Et Al. (2011). Dynamic Mathematical model of body weight change in adults. In Supplementary Webappendix [Journal-article]. https://www.niddk.nih.gov/-/media/Files/Labs-Branches-Sections/laboratory-biological-modeling/integrative-physiology-section/Hall-Lancet-Web-Appendix_508.pdf

"""
# Constants for the Hall Model
import numpy as np


RHO_F = 39.5  # Energy density of fat (MJ/kg)
RHO_L = 7.6   # Energy density of lean tissue (MJ/kg)
GAMMA_F = 0.00307  # Resting metabolic rate (RMR) coefficient for fat (MJ/kg/day)
GAMMA_L = 0.0111   # RMR coefficient for lean mass (MJ/kg/day)
DELTA = 0.078  # Physical activity cost proportional to body weight (MJ/kg/day)
BETA_TEF = 0.1  # Thermic effect of food coefficient
BETA_AT = 0.14  # Adaptive thermogenesis coefficient
TAU_AT = 14.0  # Time constant for adaptive thermogenesis (days)
K_G = 0.1  # Glycogen adjustment constant
GLYCOGEN_WATER_RATIO = 2.7  # Ratio of water to glycogen
GLYCOGEN_BASELINE = 0.5  # ~Baseline glycogen stores in kg
PAL_FACTORS = {
    "sedentary": 1.4, "lightly_active": 1.6, "moderately_active": 1.8, "active": 2.0, "very_active": 2.5
    }  # PAL factors
RMR = {
    "male": {"c": 293, "p": 0.433, "y": 5.92}, # RMR constants for Livingston-Kohlstadt formula
    "female": {"c": 248, "p": 0.4356, "y": 5.09}
} 
MJ_TO_KCAL = 239.006  # Conversion factor from MJ to kcal



# Function to calculate initial fat mass
def calculate_initial_fat_mass(sex, age, body_weight, height, body_fat_percentage=None):
    """
    Estimate initial fat mass based on sex, age, body weight and height.
    Reference: Jackson AS, Stanforth PR, Gagnon J, Rankinen T, Leon AS, Rao DC, et al. The
        effect of sex, age and race on estimating percentage body fat from body mass index: The
        Heritage Family Study. Int J Obes Relat Metab Disord. 2002; 26(6): 789-96. 

    Parameters:
        sex (str): Either "male" or "female"
        age (int): Age in years.
        body_weight (float): Total body weight in kilograms.
        height (float): Height in meters.
        body_fat_percentage (float): Initial body fat percentage. If None, it is estimated based on body weight and height.

    Returns:
        float: Initial fat mass in kilograms.
    """

    # Initial coefficients for fat mass estimation
    A = 100
    B = 0.14
    C = {"male": 37.31, "female": 39.96}
    D = {"male": -103.94, "female": -102.01}
    if body_fat_percentage is not None and body_fat_percentage > 0:
        fat_mass = body_weight * body_fat_percentage
    else:
        fat_mass = (body_weight / A) * (B * age + C[sex] * np.log((body_weight / height**2))+D[sex])
    return max(fat_mass, 0)

# Function to calculate nonlinear energy partitioning "p"
def energy_partitioning(fat_mass):
    """
    Calculate the nonlinear energy partitioning coefficient "p" based on fat mass.
    
    Parameters:
        fat_mass (float): Fat mass in kilograms.

    Returns:
        float: Nonlinear energy partitioning coefficient (dimensionless).
    
    """
    C = 10.4 * (RHO_L / RHO_F)
    p = 0
    if C + fat_mass != 0:
        p = C / (C + fat_mass)
    return p

# Function to calculate initial lean mass
def calculate_initial_lean_mass(body_weight, fat_mass, glycogen=GLYCOGEN_BASELINE, ecf=0.15):
    """
    Estimate initial lean mass by subtracting fat, glycogen, and extracellular fluid from total weight.

    Parameters:
        body_weight (float): Total body weight in kilograms.
        fat_mass (float): Fat mass in kilograms.
        glycogen (float): Glycogen stores in kilograms.
        ecf (float): Extracellular fluid in kilograms.

    Returns:
        float: Lean mass in kilograms.
    """
    return max(body_weight - fat_mass - glycogen - ecf, 0)

# Function to calculate glycogen dynamics
def calculate_glycogen_dynamics(current_ci, baseline_ci):
    """
    Compute glycogen changes based on carbohydrate intake.

    Parameters:
        current_ci (float): Current carbohydrate intake in grams/day.
        baseline_ci (float): Baseline carbohydrate intake in grams/day.

    Returns:
        float: Rate of change of glycogen in kilograms/day.
    """
    delta_ci = current_ci - baseline_ci
    return K_G * delta_ci / 1000  # Convert grams to kilograms

# Function to calculate extracellular fluid dynamics
def calculate_ecf_dynamics(delta_na, delta_ci, xi_na, xi_ci):
    """
    Compute extracellular fluid changes based on sodium and carbohydrate intake variations.

    Parameters:
        delta_na (float): Change in dietary sodium intake (mmol/day).
        delta_ci (float): Change in carbohydrate intake (grams/day).
        xi_na (float): Sodium sensitivity coefficient.
        xi_ci (float): Carbohydrate sensitivity coefficient.

    Returns:
        float: Rate of change of extracellular fluid in kilograms/day.
    """
    return xi_na * delta_na + xi_ci * delta_ci / 1000  # Convert grams to kilograms

# Function to calculate total energy expenditure
def calculate_tee(body_weight, age, sex, energy_intake, adaptive_thermogenesis=0, pal_factor=PAL_FACTORS["sedentary"]):
    """
    Calculate total energy expenditure (TEE).

    Parameters:
        fat_mass (float): Fat mass in kilograms.
        lean_mass (float): Lean mass in kilograms.
        body_weight (float): Total body weight in kilograms.
        energy_intake (float): Energy intake in MJ/day.

    Returns:
        float: Total energy expenditure in MJ/day.
    """
    rmr = calculate_rmr(body_weight, age, sex)
    pa = calculate_pa(body_weight, rmr, pal_factor)
    tef = calculate_tef(energy_intake)
    return rmr + pa + tef + adaptive_thermogenesis

def calculate_tef(energy_intake):
    """
    Calculate the thermic effect of food (TEF).

    Parameters:
        energy_intake (float): Energy intake in MJ/day.

    Returns:
        float: Thermic effect of food in MJ/day.
    """
    return BETA_TEF * energy_intake

def calculate_pa(body_weight, rmr, pal_factor=PAL_FACTORS["sedentary"]):
    """
    Calculate physical activity energy expenditure (PA) in MJ/day, adjusted for PAL.

    Parameters:
        body_weight (float): Total body weight in kilograms.
        rmr (float): Resting metabolic rate (RMR) in MJ/day.
        pal_factor (float): Physical activity level (PAL). Default is 1.4 for sedentary.

    Returns:
        float: Physical activity energy expenditure in MJ/day.
    """
    delta = ((1 - BETA_TEF) * pal_factor - 1) * rmr / body_weight
    return delta * body_weight


# Functions
def calculate_rmr(weight, age, sex):
    """
    Calculate the Resting Metabolic Rate (RMR) based on weight, age, and sex using
    the Livingston-Kohlstadt formula.
    
    Parameters:
        weight (float): Weight in kilograms.
        age (float): Age in years.
        sex (str): 'male' or 'female'.
    
    Returns:
        float: Resting Metabolic Rate (RMR) in MJ/day.
    """
    c, p, y = RMR[sex].values()
    rmr = c * (max(weight, 0) ** p) - y * age
    rmr /= 239.006  # Convert kcal/day to MJ/day
    return max(rmr, 0)

# Function to calculate adaptive thermogenesis
def calculate_adaptive_thermogenesis(delta_ei, at_old):
    """
    Compute adaptive thermogenesis based on energy intake changes.

    Parameters:
        delta_ei (float): Change in energy intake (MJ/day).
        time (float): Time elapsed (days).

    Returns:
        float: Adaptive thermogenesis in MJ/day.
    """
    dAT_dt = (BETA_AT * delta_ei - at_old) / TAU_AT
    at_new = at_old + dAT_dt * 1  # Time step of 1 day
    return at_new

# Function to simulate weight changes over time
def simulate_hall_model(duration_days, sex, age, body_weight, height, energy_intake, baseline_ci, baseline_ei, body_fat_percentage=None, pal_factor=PAL_FACTORS["sedentary"]):
    """
    Simulate weight changes using the Hall model.

    Parameters:
        duration_days (int): Simulation duration in days.
        sex (str): Either "male" or "female"
        age (int): Age in years.
        body_weight (float): Initial body weight in kilograms.
        height (float): Height in meters.
        energy_intake (float): Energy intake in MJ/day.
        baseline_ci (float): Baseline carbohydrate intake in grams/day.
        baseline_ei (float): Baseline energy intake (maintenance calories at beginning) in MJ/day.
        body_fat_percentage (float): Initial body fat percentage. If None, it is estimated based on body weight and height.
        pal_factor (float): Physical activity level (PAL), a multiplier for total energy expenditure in the range of 1.4 to 2.5.

    Returns:
        list: Simulation results containing daily weight, body fat percentage, fat mass, lean mass and its components, and TEE and its components
    """
    fat_mass = calculate_initial_fat_mass(sex, age, body_weight, height, body_fat_percentage)
    glycogen = 0.5  # Initial glycogen stores in kg
    ecf = 2.0       # Initial extracellular fluid in kg
    lean_mass = calculate_initial_lean_mass(body_weight, fat_mass, glycogen, ecf)
    at = 0 # Initial adaptive thermogenesis
    rmr = calculate_rmr(body_weight, age, sex)
    pa = calculate_pa(body_weight, rmr, pal_factor)
    tef = calculate_tef(energy_intake)
    tee = rmr + pa + tef + at

    results = [{
        "day": 0, 
        "weight": body_weight,
        "body_fat_percentage": fat_mass / body_weight,
        "fat_mass": fat_mass,
        "lean_mass": lean_mass,
        "glycogen": glycogen,
        "ecf": ecf,
        "tee": tee * MJ_TO_KCAL,
        "at": at * MJ_TO_KCAL,
        "rmr": rmr * MJ_TO_KCAL,
        "tef": tef * MJ_TO_KCAL,
        "pa": pa * MJ_TO_KCAL
    }]

    for day in range(1, duration_days-1):
        # Update TEE components
        delta_ei = energy_intake - baseline_ei # Energy intake change from baseline
        at = calculate_adaptive_thermogenesis(delta_ei, at)
        rmr = calculate_rmr(body_weight, age, sex)
        pa = calculate_pa(body_weight, rmr, pal_factor)
        tef = calculate_tef(energy_intake)
        tee = rmr + pa + tef + at
        delta_energy = energy_intake - tee # Energy imbalance
        
        # Energy partitioning
        p = energy_partitioning(fat_mass)
        dF_dt = (1 - p) * delta_energy / RHO_F
        dL_dt = p * delta_energy / RHO_L

        # Update masses
        fat_mass = max(fat_mass + dF_dt, 0)
        lean_mass = max(lean_mass + dL_dt, 0)

        # Glycogen and ECF dynamics
        dG_dt = calculate_glycogen_dynamics(energy_intake, baseline_ci)
        glycogen = max(glycogen + dG_dt, 0)

        dECF_dt = calculate_ecf_dynamics(0, 0, 0.005, 0.001)  # Example coefficients
        ecf = max(ecf + dECF_dt, 0)

        # Update body weight
        body_weight = fat_mass + lean_mass + glycogen + ecf

        # Store results
        results.append({
            "day": day,
            "weight": body_weight,
            "body_fat_percentage": fat_mass / body_weight,
            "fat_mass": fat_mass,
            "lean_mass": lean_mass,
            "glycogen": glycogen,
            "ecf": ecf,
            "tee": tee * MJ_TO_KCAL, 
            "at": at * MJ_TO_KCAL,
            "rmr": rmr * MJ_TO_KCAL,
            "tef": tef * MJ_TO_KCAL,
            "pa": pa * MJ_TO_KCAL
        })


    return results

def calculate_energy_intake_for_target_weight(duration_days, target_weight, sex, age, body_weight, height, baseline_ci, baseline_ei, body_fat_percentage=None, pal_factor=PAL_FACTORS["sedentary"], tolerance=0.01):
    """
    Calculate the required energy intake to reach a target weight within a given time.

    Parameters:
        duration_days (int): Number of days to reach the target weight.
        target_weight (float): Desired target weight in kilograms.
        sex (str): "male" or "female".
        age (int): Age in years.
        body_weight (float): Initial body weight in kilograms.
        height (float): Height in meters.
        baseline_ci (float): Baseline carbohydrate intake in grams/day.
        baseline_ei (float): Baseline energy intake in MJ/day.
        body_fat_percentage (float): Initial body fat percentage.
        pal_factor (float): Physical activity level (PAL).
        tolerance (float): Allowable weight difference to consider the target met.

    Returns:
        tuple: (results, required_energy_intake, maintenance_calories)
            results: Simulation results.
            required_energy_intake: Energy intake (kcal/day) needed to achieve the target weight.
            maintenance_calories: TEE (kcal/day) to maintain the target weight.
    """
    # Start with an initial guess for energy intake
    low_ei = 1.0  # Lower bound for energy intake (MJ/day)
    high_ei = 20.0  # Upper bound for energy intake (MJ/day)
    required_energy_intake = (low_ei + high_ei) / 2.0  # Midpoint initial guess

    while high_ei - low_ei > 0.01:  # Iterate until energy intake is refined
        results = simulate_hall_model(
            duration_days, sex, age, body_weight, height, required_energy_intake, baseline_ci, baseline_ei, body_fat_percentage, pal_factor
        )
        final_weight = results[-1]["weight"]

        if abs(final_weight - target_weight) <= tolerance:
            # Target weight is reached within tolerance
            maintenance_calories = results[-1]["tee"] 
            return results, required_energy_intake * MJ_TO_KCAL, maintenance_calories
        elif final_weight > target_weight:
            # Weight is too high, reduce energy intake
            high_ei = required_energy_intake
        else:
            # Weight is too low, increase energy intake
            low_ei = required_energy_intake

        required_energy_intake = (low_ei + high_ei) / 2.0

    # If we exit the loop without finding the exact target, return the closest result
    results = simulate_hall_model(
        duration_days, sex, age, body_weight, height, required_energy_intake, baseline_ci, baseline_ei, body_fat_percentage, pal_factor
    )
    maintenance_calories = results[-1]["tee"]
    return results, required_energy_intake * MJ_TO_KCAL, maintenance_calories


"""
Thomas Model Test
=================

This script tests the Thomas et al. (2011) model for predicting weight loss or gain over time.
The model is based on differential equations that describe changes in fat mass and fat-free mass (lean mass)
based on energy balance and body composition.
The model also calculates total energy expenditure (TEE) and its components, including Resting Metabolic Rate (RMR),
Dietary-Induced Thermogenesis (DIT), Spontaneous Physical Activity (SPA), and Physical Activity (PA).
The simulation is run over a specified duration, and the results are plotted and displayed in tabular format.
The user can input sex, age, weight, height, energy intake, and duration to run the simulation.

@author: Lincoln Quick

References: 
Forbes GB. Longitudinal changes in adult fat-free mass: influence of body weight. Am J Clin Nutr. Dec 1999;70(6):1025-1031.
Gilbert B. Forbes, Lean Body Mass-Body Fat Interrelationships in Humans, Nutrition Reviews, Volume 45, Issue 10, October 1987, Pages 225–231, https://doi.org/10.1111/j.1753-4887.1987.tb02684.x
Hall, K. D. (2007). Body fat and fat-free mass inter-relationships: Forbes’s theory revisited. British Journal of Nutrition, 97(6), 1059–1063. doi:10.1017/S0007114507691946
Livingston EH, Kohlstadt I. Simplified resting metabolic rate-predicting formulas for normal-sized and obese individuals. Obes Res. Jul 2005;13(7):1255-1262.
Martin CK, Heilbronn LK, de Jonge L, et al. Effect of calorie restriction on resting metabolic rate and spontaneous physical activity. Obesity (Silver Spring). Dec 2007;15(12):2964-2973.
Thomas, D. M., Martin, C. K., Heymsfield, S., Redman, L. M., Schoeller, D. A., & Levine, J. A. (2011). A Simple Model Predicting Individual Weight Change in Humans. Journal of biological dynamics, 5(6), 579–599. https://doi.org/10.1080/17513758.2010.508541
Thomas, D. M., Gonzalez, M. C., Pereira, A. Z., Redman, L. M., & Heymsfield, S. B. (2014). Time to correctly predict the amount of weight loss with dieting. Journal of the Academy of Nutrition and Dietetics, 114(6), 857–861. https://doi.org/10.1016/j.jand.2014.02.003
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import io
import mplcursors
import scipy.optimize as opt
from scipy.optimize import fsolve


# Constants
CF = 1020  # Energy density of FFM (kcal/kg)
CL = 9500  # Energy density of FM (kcal/kg)
S_LOSS = 2 / 3 # Constant used to calculate SPA during weight loss
S_GAIN = 0.56 # Constant used to calculate SPA during weight gain 
BETA_LOSS = 0.075 # Constant used to calculate DIT during weight loss
BETA_GAIN = 0.086 # Constant used to calculate DIT during weight gain
RMR = {"male": {"c": 293, "p": 0.433, "y": 5.92}, # RMR constants for Livingston-Kohlstadt formula
       "female": {"c": 248, "p": 0.4356, "y": 5.09}} 
BASELINE_SPA_FACTOR = 0.326 # SPA(0) = 0.326 * E(0) or baseline energy
CONVERSION_FACTOR = 2.20462  # lbs to kg conversion factor
ESSENTIAL_FAT_MASS = {"male":2.5, "female":5}  # Essential fat mass in kg, smallest healthy fat mass
ESSENTIAL_LEAN_MASS = {"male": 18, "female": 18} # Smallest healthy lean mass in kg, smallest healthy lean mass

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
    return max(m * weight, 0)

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
    return max(beta * energy_intake, 0)

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
    according to the differential equations proposed by Thomas (2011).
    
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
    This calculation is used when the user enters a weight and does not provide a fat mass or 
    body fat percentage.

    W0 = FFM(0) + F(0), where W(0) is the initial weight provided by the user, FFM(0) is the initial fat-free mass
    calculated based on the NHANES FFM formula proposed by Thomas and Heymsfield (2011), and F(0) is the initial fat mass.

    weight_kg = calculate_ffm(fat_mass, age, 0, height, sex) + fat_mass

    Parameters:
        weight_kg (float): Weight in kilograms.
        age (int): Age in years.
        height_cm (float): Height in centimeters.
        sex (str): "male" or "female"

    Returns:
        float: Baseline fat mass in kilograms.
    """
    # t = 0  # Fixed time value for calculation

    # # Define the equation to solve: weight_kg = ffm + fat_mass
    # def equation(fat_mass):
    #     ffm = calculate_ffm(fat_mass, age, t, height_cm, sex)
    #     return ffm + fat_mass - weight_kg

    # # Use numerical solver to find the root (fat_mass)
    # result = opt.root_scalar(equation, bracket=[0, weight_kg], method='brentq')
    # if result.converged:
    #     return result.root
    # else:
    #     raise ValueError("Failed to converge on a solution for fat_mass.")
    if sex == "male":
        return max(24.96493 + 0.064761 * age - 0.28889 * height_cm + 0.55342 * weight_kg, 0)
    elif sex == "female":
        return max(18.19812 + 0.043109 * age - 0.23014 * height_cm + 0.641413 * weight_kg, 0)
    else:
        raise ValueError("Sex must be 'male' or 'female'.")




def calculate_baseline_energy_requirements(weight_kg, age, height_cm, sex):
    """
    Calculate baseline energy requirements based on weight and sex using the quadratic regression analysis
    performed by Thomas (2011) (equation 3).
    
    This is used when the user does not provide an total energy expenditure (TEE) value 
    (also referred to as baseline energy or maintenance calories).

    Parameters:
        weight_kg (float): Weight in kilograms.
        age (int): Age in years. (not used in this implementation)
        height_cm (float): Height in centimeters. (not used in this implementation)
        sex (str): "male" or "female"

    Returns:   
        float: Baseline energy requirements in kcal/day.
    """
    # if sex == "male":
    #     return max(892.721 - 16.7 * age + 1.29 * height_cm + 42.9 * weight_kg - 0.11435 * weight_kg**2, 0)
    # elif sex == "female":
    #     return max(430.29 - 12.86 * age + 12.19 * height_cm + 4.066 * weight_kg + 0.043 * weight_kg**2, 0)
    # else:
    #     raise ValueError("Sex must be 'male' or 'female'.")

    if sex == "male":
        return -0.0971 * weight_kg**2 + 40.853 * weight_kg + 323.59
    elif sex == "female":
        return 0.0278 * weight_kg**2 + 9.2893 * weight_kg + 1528.9
    else:
        raise ValueError("Sex must be 'male' or 'female'.")

# Function for partial derivatives
def calculate_partial_derivatives(fat_mass, age, t, height, sex):
    """
    Calculate numerical partial derivatives of FFM with respect to fat_mass and time.
    """
    epsilon = 1e-5  # Small perturbation
    # Partial derivative with respect to fat_mass
    ffm_f_plus = calculate_ffm(fat_mass + epsilon, age, t, height, sex)
    ffm_f_minus = calculate_ffm(fat_mass - epsilon, age, t, height, sex)
    dFFM_dF = (ffm_f_plus - ffm_f_minus) / (2 * epsilon)

    # Partial derivative with respect to time
    ffm_t_plus = calculate_ffm(fat_mass, age, t + epsilon, height, sex)
    ffm_t_minus = calculate_ffm(fat_mass, age, t - epsilon, height, sex)
    dFFM_dt = (ffm_t_plus - ffm_t_minus) / (2 * epsilon)

    return dFFM_dF, dFFM_dt

def run_simulation(sex, age, weight_kg, height_cm, energy_intake, duration_days, body_fat_percentage=0):
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

    # Use user input for body fat percentage if provided, otherwise estimate baseline fat mass
    if (body_fat_percentage is None or body_fat_percentage <= 0):
        fat_mass = calculate_baseline_fat_mass(weight_kg, age, height_cm, sex)
    else:
        fat_mass = weight_kg * body_fat_percentage
    ffm = weight_kg - fat_mass

    rmr = calculate_rmr(weight_kg, age, sex)
    dit = calculate_dit(energy_intake, weight_change_phase)
    
    spa0 = BASELINE_SPA_FACTOR * baseline_energy # initial SPA needed to calculate PA
    pa = calculate_baseline_pa(baseline_energy, dit, spa0, rmr) 
    constant_c = calculate_constant_c(baseline_energy, rmr, pa, dit, weight_change_phase)
    # Recalculate SPA with constant_c, should equal spa0
    spa = calculate_spa(rmr, pa, dit, weight_change_phase, constant_c) 
   
    # TEE should now equal baseline_energy
    print(f"Baseline Energy: {baseline_energy:.2f} kcal/day, Initial TEE: {rmr + dit + spa + pa:.2f} kcal/day")
    tee = rmr + dit + spa + pa

    results = []
    results.append({
            "day": 0,
            "weight": weight_kg,
            "fat_mass": fat_mass,
            "lean_mass": ffm,
            "body_fat_percentage": fat_mass / weight_kg,
            "tee": tee,
            "rmr": rmr,
            "dit": dit,
            "spa": spa,
            "pa": pa
        })

    # Iterate / integrate the calculations over the specified duration with an interval of 1 day
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

        # Calculate partial derivatives
        dFFM_dF, dFFM_dt = calculate_partial_derivatives(fat_mass, age, day, height_cm, sex)

        # Define the coupled equations
        def coupled_equations(d_vars):
            dF_dt = d_vars[0]
            dFFM_dt_calc = dFFM_dF * dF_dt + dFFM_dt
            eq1 = CL * dFFM_dt_calc + CF * dF_dt - delta_energy  # Energy balance equation
            return [eq1]

        # Solve for dF/dt
        dF_dt = fsolve(coupled_equations, [0])[0]

        # Calculate dFFM/dt using the relationship
        dFFM_dt = dFFM_dF * dF_dt + dFFM_dt


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
        rmr = calculate_rmr(weight_kg, age + day/365, sex)
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
            "body_fat_percentage": fat_mass / weight_kg,
            "tee": tee,
            "rmr": rmr,
            "dit": dit,
            "spa": spa,
            "pa": pa
        })
    return results


# Plotting Functions

def create_weight_loss_plot(results):
    """
    Generate the weight loss plot (weight, fat mass, and lean mass) over time.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
    """
    days = [res['day'] for res in results]
    weights = [res['weight'] * CONVERSION_FACTOR for res in results]
    fat_mass = [res['fat_mass'] * CONVERSION_FACTOR for res in results]
    lean_mass = [res['lean_mass'] * CONVERSION_FACTOR for res in results]

    matplotlib.use('Agg')

    plt.figure(figsize=(10, 6))
    weight_line, = plt.plot(days, weights, label='Total Weight (lbs)', linewidth=2)
    fat_mass_line, = plt.plot(days, fat_mass, label='Fat Mass (lbs)', linewidth=2, linestyle='--')
    lean_mass_line, = plt.plot(days, lean_mass, label='Lean Mass (lbs)', linewidth=2, linestyle=':')
    plt.title('Weight, Fat Mass, and Lean Mass Over Time', fontsize=16)
    plt.xlabel('Days', fontsize=14)
    plt.ylabel('Weight (lbs)', fontsize=14)
    plt.legend()
    plt.grid(True)

    # Add interactive hover for local display
    cursor = mplcursors.cursor([weight_line, fat_mass_line, lean_mass_line], hover=True)
    cursor.connect(
        "add",
        lambda sel: sel.annotation.set_text(
            f"Day: {days[int(sel.target[0])]}, Value: {sel.target[1]:.2f}"
        )
    )

def save_weight_loss_plot(results):
    """
    Generate the plot and save it to memory for use in Flask.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]

    Returns:
        io.BytesIO: BytesIO object containing the saved image.
    """
    create_weight_loss_plot(results)  # Generate the plot
    image_buffer = io.BytesIO()
    plt.savefig(image_buffer, format='png')  # Save to memory
    image_buffer.seek(0)  # Reset buffer position to the beginning
    plt.close()  # Close the figure to free memory
    return image_buffer

def get_weight_loss_plot_image(results):
    """
    Create a plot and return its image data for use in Flask app.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]

    Returns:
        bytes: Image data in PNG format.
    """
    image_buffer = save_weight_loss_plot(results)
    return image_buffer.getvalue()  # Return raw image data

def plot_weight_loss_display(results):
    """
    Generate and display the weight loss plot locally.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
    """
    create_weight_loss_plot(results)  # Generate the plot
    plt.show()  # Display the plot locally


def create_energy_expenditure_plot(results):
    """
    Generate the energy expenditure plot (TEE, RMR, DIT, SPA, PA) over time.

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

    matplotlib.use('Agg')

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

    # Add interactive hover for local display
    cursor = mplcursors.cursor([tee_line, rmr_line, dit_line, spa_line, pa_line], hover=True)
    cursor.connect(
        "add",
        lambda sel: sel.annotation.set_text(
            f"Day: {days[int(sel.target[0])]}, Value: {sel.target[1]:.2f}"
        )
    )

def save_energy_expenditure_plot(results):
    """
    Generate the energy expenditure plot and save it to memory for use in Flask.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]

    Returns:
        io.BytesIO: BytesIO object containing the saved image.
    """
    create_energy_expenditure_plot(results)  # Generate the plot
    image_buffer = io.BytesIO()
    plt.savefig(image_buffer, format='png')  # Save to memory
    image_buffer.seek(0)  # Reset buffer position to the beginning
    plt.close()  # Close the figure to free memory
    return image_buffer

def get_energy_expenditure_plot_image(results):
    """
    Create a plot and return its image data for use in Flask app.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]

    Returns:
        bytes: Image data in PNG format.
    """
    image_buffer = save_energy_expenditure_plot(results)
    return image_buffer.getvalue()  # Return raw image data

def plot_energy_expenditure_display(results):
    """
    Generate and display the energy expenditure plot locally.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
    """
    create_energy_expenditure_plot(results)  # Generate the plot
    plt.show()  # Display the plot locally



def print_results(results):
    """
    
    Print the results of the simulation in tabular format.
    
    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
        
    """
    print("Day\tWeight(lb)\tBody Fat (%)\tFat Mass(lb)\tLean Mass(lb)\tTEE(kcal)\tRMR(kcal)\tDIT(kcal)\tSPA(kcal)\tPA(kcal)")
    for res in results:
        body_fat_percentage = res['fat_mass'] / res['weight'] * 100.0
        print(f"{res['day']}\t{res['weight']*CONVERSION_FACTOR:.2f}\t\t{body_fat_percentage:.2f}%\t\t{res['fat_mass']*CONVERSION_FACTOR:.2f}\t\t{res['lean_mass']*CONVERSION_FACTOR:.2f}\t\t{res['tee']:.2f}\t\t{res['rmr']:.2f}\t\t{res['dit']:.2f}\t\t{res['spa']:.2f}\t\t{res['pa']:.2f}")

def get_user_input():
    """
    Get user input for running the simulation, allowing the user to choose between entering 
    total caloric intake, calorie deficit, or calorie surplus.

    Returns:
        tuple: A tuple containing the user input values (sex, age, weight, height, energy_intake, duration).
    """
    choice = input("Would you like to run the simulation by entering your \ntotal daily caloric intake (i), "
                   "\na set calorie deficit (d), \nor a set calorie surplus (s)? \t").strip().lower()
    
    sex = input("Enter sex (male/female): ").strip().lower()
    age = int(input("Enter age (years): "))
    weight_lbs = float(input("Enter weight (lbs): "))
    height_in = float(input("Enter height (in): "))
    duration = int(input("Enter duration (days): "))
    
    # Convert weight and height to metric units
    weight = weight_lbs / CONVERSION_FACTOR
    height = height_in * 2.54
    
    baseline_energy = calculate_baseline_energy_requirements(weight, age, height, sex)

    if choice == "i":
        energy_intake = float(input("Enter energy intake (kcal/day): "))
    elif choice == "d":
        deficit = float(input("Enter calorie deficit (kcal/day): "))
        energy_intake = baseline_energy - deficit
    elif choice == "s":
        surplus = float(input("Enter calorie surplus (kcal/day): "))
        energy_intake = baseline_energy + surplus
    else:
        raise ValueError("Invalid choice. Please enter 'i', 'd', or 's'.")
    
    print(f"\nRunning simulation for {duration} days with the following parameters:")
    print(f"Sex: {sex}, Age: {age}, Weight: {weight:.2f} kg, Height: {height:.2f} cm\n")
    print(f"Energy Intake: {energy_intake:.2f} kcal/day, Energy Expenditure: {baseline_energy:.2f} kcal/day")
    print(f"Initial Energy Balance: {energy_intake - baseline_energy:.2f} kcal/day\n")
    print(f"Note: This model assumes constant daily energy intake with changing energy expenditure over time.")
    print(f"This model estimates initial fat mass and energy expendtiure based on weight, age, and sex using linear regression models.")
    print(f"This results in a slight 'plateau' effect in weight loss or gain and predicts a longer time to lose weight when compared to the traditional '3500 kcal per pound' rule.\n")

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
    plot_weight_loss_display(results)
    plot_energy_expenditure_display(results)

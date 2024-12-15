import numpy as np
from scipy.optimize import fsolve
from thomas_model import calculate_baseline_fat_mass, calculate_rmr, calculate_dit, calculate_pa, calculate_spa, CL, CF, calculate_partial_derivatives

# Function to smooth weight data based on trends
def smooth_weight_data(weight_data):
    """
    Smooth noisy weight data based on the overall trend.

    Parameters:
        weight_data (dict): A dictionary with dates as keys and weights (in kg) as values.

    Returns:
        dict: A smoothed version of the weight data.
    """
    dates = list(weight_data.keys())
    weights = list(weight_data.values())

    # Calculate daily changes
    daily_changes = np.diff(weights)
    avg_change = np.mean(daily_changes)

    # Generate smoothed weights based on the trend
    smoothed_weights = [weights[0]]  # Start with the initial weight
    for i in range(1, len(weights)):
        smoothed_weights.append(smoothed_weights[-1] + avg_change)

    # Adjust for reversing trends
    for i in range(1, len(weights)):
        if (weights[i] - weights[i - 1]) * avg_change < 0:  # Detect trend reversal
            smoothed_weights[i] = weights[i]  # Align with actual data

    return {date: smoothed_weights[i] for i, date in enumerate(dates)}

# Function to estimate caloric intake from weight data
def estimate_caloric_intake(weight_data, sex, age, height_cm):
    """
    Estimate caloric intake based on weight data and the Thomas model.

    Parameters:
        weight_data (dict): A dictionary with dates as keys and weights (in kg) as values.
        sex (str): "male" or "female".
        age (int): Age in years.
        height_cm (float): Height in centimeters.

    Returns:
        float: Estimated average daily caloric intake.
    """
    # Smooth the weight data
    smoothed_data = smooth_weight_data(weight_data)

    # Extract smoothed weights and calculate daily changes
    dates = list(smoothed_data.keys())
    weights = list(smoothed_data.values())
    daily_changes = np.diff(weights)

    # Initialize variables for estimation
    estimated_intakes = []
    fat_mass = calculate_baseline_fat_mass(weights[0], age, height_cm, sex)
    ffm = weights[0] - fat_mass

    for i, delta_weight in enumerate(daily_changes):
        rmr = calculate_rmr(weights[i], age + i / 365, sex)
        dit = calculate_dit(rmr, "loss" if delta_weight < 0 else "gain")
        pa = calculate_pa(weights[i], 0.3 * rmr, weights[0])  # Assume 30% of RMR for baseline PA
        spa = calculate_spa(rmr, pa, dit, "loss" if delta_weight < 0 else "gain", 0)
        tee = rmr + dit + pa + spa

        # Define equations for dF/dt and dFFM/dt
        def coupled_equations(d_vars):
            dF_dt, dFFM_dt = d_vars
            eq1 = CL * dFFM_dt + CF * dF_dt - (delta_weight * 7700)  # Energy balance
            eq2 = dFFM_dt - calculate_partial_derivatives(fat_mass, age, i, height_cm, sex)[1]
            return [eq1, eq2]

        # Solve for changes in fat and FFM
        dF_dt, dFFM_dt = fsolve(coupled_equations, [0, 0])
        fat_mass += dF_dt
        ffm += dFFM_dt

        # Estimate caloric intake
        estimated_intakes.append(tee + (delta_weight * 7700))

    # Return the average caloric intake
    return np.mean(estimated_intakes)

# Example usage
data = {
    "2024-01-01": 85,
    "2024-01-02": 84.9,
    "2024-01-03": 84.8,
    "2024-01-04": 84.7,
    "2024-01-05": 84.6,
}

smoothed_data = smooth_weight_data(data)
print("Smoothed Data:", smoothed_data)

estimated_calories = estimate_caloric_intake(data, "male", 35, 175)
print("Estimated Daily Caloric Intake:", estimated_calories)

def test_caloric_intake_estimation():
    """
    Test the caloric intake estimation function with predefined inputs and expected results.
    """
    test_data = {
        "2024-01-01": 80,
        "2024-01-02": 79.9,
        "2024-01-03": 79.8,
        "2024-01-04": 79.7,
        "2024-01-05": 79.6,
    }


    expected_smoothed_data = {
        "2024-01-01": 80,
        "2024-01-02": 79.95,
        "2024-01-03": 79.9,
        "2024-01-04": 79.85,
        "2024-01-05": 79.8,
    }

    variance = 0.001 # Tolerance for floating-point comparison

    expected_calories = 1800  # Hypothetical expected average caloric intake

    # Perform the test
    smoothed = smooth_weight_data(test_data)
    for date in smoothed.keys():
        smooth = smoothed[date]
        expected = expected_smoothed_data[date]
        assert abs(smooth - expected) < variance, f"Smoothed data mismatch. Got {smooth}, expected {expected}."
    

    estimated_calories = estimate_caloric_intake(test_data, "male", 30, 175)
    assert abs(estimated_calories - expected_calories) < 50, (
        f"Caloric intake estimation mismatch. Got {estimated_calories}, expected {expected_calories}."
    )

    print("All tests passed.")

if __name__ == "__main__":  
    # Run the test
    test_caloric_intake_estimation()


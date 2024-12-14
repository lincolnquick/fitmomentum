from thomas_model import run_simulation, print_results

# Define a function to run and analyze the test cases
def run_and_compare_thomas_model():
    """
    Run the Thomas Model on test cases derived from real studies and compare the results.
    """
    # Test Case 1: iDip Study
    print("Test Case 1: iDip Study")
    sex = "female"
    age = 28
    weight_kg = 60  # kg
    height_cm = 165  # cm
    energy_intake = 1500  # kcal/day
    duration_days = 365  # 1 year
    expected_weight_loss = 7.74  # kg
    results_idip = run_simulation(sex, age, weight_kg, height_cm, energy_intake, duration_days)
    final_weight_idip = results_idip[-1]['weight']
    actual_weight_loss_idip = weight_kg - final_weight_idip
    print_results(results_idip)
    print(f"Predicted Weight Loss: {actual_weight_loss_idip:.2f} kg")
    print(f"Expected Weight Loss: {expected_weight_loss:.2f} kg")
    print(f"Deviation: {abs(actual_weight_loss_idip - expected_weight_loss):.2f} kg\n")

    # Test Case 2: Minnesota Starvation Study
    print("Test Case 2: Minnesota Starvation Study")
    sex = "male"
    age = 25
    weight_kg = 70  # kg
    height_cm = 175  # cm
    energy_intake = 1560  # kcal/day
    duration_days = 168  # 24 weeks
    expected_weight_loss = 17.5  # kg
    results_minnesota = run_simulation(sex, age, weight_kg, height_cm, energy_intake, duration_days)
    final_weight_minnesota = results_minnesota[-1]['weight']
    actual_weight_loss_minnesota = weight_kg - final_weight_minnesota
    print_results(results_minnesota)
    print(f"Predicted Weight Loss: {actual_weight_loss_minnesota:.2f} kg")
    print(f"Expected Weight Loss: {expected_weight_loss:.2f} kg")
    print(f"Deviation: {abs(actual_weight_loss_minnesota - expected_weight_loss):.2f} kg\n")

    # Test Case 3: Moderate Caloric Deficit
    print("Test Case 3: Moderate Caloric Deficit")
    sex = "male"
    age = 35
    weight_kg = 85  # kg
    height_cm = 175  # cm
    energy_intake = 2000  # kcal/day
    duration_days = 60  # 2 months
    expected_weight_loss = 4.5  # kg (estimated)
    results_moderate_deficit = run_simulation(sex, age, weight_kg, height_cm, energy_intake, duration_days)
    final_weight_moderate_deficit = results_moderate_deficit[-1]['weight']
    actual_weight_loss_moderate_deficit = weight_kg - final_weight_moderate_deficit
    print_results(results_moderate_deficit)
    print(f"Predicted Weight Loss: {actual_weight_loss_moderate_deficit:.2f} kg")
    print(f"Expected Weight Loss: {expected_weight_loss:.2f} kg")
    print(f"Deviation: {abs(actual_weight_loss_moderate_deficit - expected_weight_loss):.2f} kg\n")

    return results_idip, results_minnesota, results_moderate_deficit

# Execute the test cases
test_results = run_and_compare_thomas_model()

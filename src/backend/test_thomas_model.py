# test_thomas_model.py

import os
from thomas_model import run_simulation

# Define test datasets
datasets = [
    {
        "study": "Racette et al. (2006)",
        "sex": "male",
        "age": 55,
        "weight_kg": 78.5,
        "height_cm": 170,
        "energy_intake": 2493 * (1 - 0.115),  # 11.5% reduction
        "duration_days": 365,
        "body_fat_percentage": 25.9 / 78.5,  # Baseline fat mass percentage
        "expected": {
            "weight": 70.5,
            "fat_mass": 19.7,
            "ffm": 51.9,
        },
    },
    {
        "study": "Martin et al. (2011)",
        "sex": "female",
        "age": 45,
        "weight_kg": 70.2,
        "height_cm": 165,
        "energy_intake": 2000 * 0.8,  # 20% reduction
        "duration_days": 180,  # 6 months
        "body_fat_percentage": 30.0 / 70.2,  # Baseline fat mass percentage
        "expected": {
            "weight": 65.1,
            "fat_mass": 25.0,
            "ffm": 40.1,
        },
    },
    {
        "study": "Leibel et al. (1995)",
        "sex": "male",
        "age": 40,
        "weight_kg": 90.0,
        "height_cm": 180,
        "energy_intake": 3000 * 0.85,  # 15% reduction
        "duration_days": 90,  # 3 months
        "body_fat_percentage": 27.0 / 90.0,  # Baseline fat mass percentage
        "expected": {
            "weight": 85.0,
            "fat_mass": 23.0,
            "ffm": 62.0,
        },
    },
]

# Run tests and save results
output_filename = "test_thomas_model_results.txt"
with open(output_filename, "w") as file:
    file.write("Thomas Model Testing Results\n")
    file.write("=" * 50 + "\n\n")

    for dataset in datasets:
        # Extract parameters
        study = dataset["study"]
        sex = dataset["sex"]
        age = dataset["age"]
        weight_kg = dataset["weight_kg"]
        height_cm = dataset["height_cm"]
        energy_intake = dataset["energy_intake"]
        duration_days = dataset["duration_days"]
        body_fat_percentage = dataset["body_fat_percentage"]
        expected = dataset["expected"]

        # Run simulation
        results = run_simulation(
            sex=sex,
            age=age,
            weight_kg=weight_kg,
            height_cm=height_cm,
            energy_intake=energy_intake,
            duration_days=duration_days,
            body_fat_percentage=body_fat_percentage,
        )

        # Extract end-of-simulation results
        final_day = results[-1]
        predicted_weight = final_day["weight"]
        predicted_fat_mass = final_day["fat_mass"]
        predicted_ffm = final_day["lean_mass"]

        # Calculate percentage errors
        weight_error = abs(predicted_weight - expected["weight"]) / expected["weight"] * 100
        fat_mass_error = abs(predicted_fat_mass - expected["fat_mass"]) / expected["fat_mass"] * 100
        ffm_error = abs(predicted_ffm - expected["ffm"]) / expected["ffm"] * 100

        # Write results to file
        file.write(f"Study: {study}\n")
        file.write("-" * 50 + "\n")
        file.write(f"Parameters:\n")
        file.write(f"Sex: {sex}\n")
        file.write(f"Age: {age} years\n")
        file.write(f"Initial Weight: {weight_kg:.2f} kg\n")
        file.write(f"Height: {height_cm:.2f} cm\n")
        file.write(f"Energy Intake: {energy_intake:.2f} kcal/day\n")
        file.write(f"Duration: {duration_days} days\n")
        file.write(f"Baseline Body Fat Percentage: {body_fat_percentage * 100:.2f}%\n\n")
        file.write(f"Results:\n")
        file.write(f"Predicted Weight: {predicted_weight:.2f} kg (Expected: {expected['weight']:.2f} kg)\n")
        file.write(f"Predicted Fat Mass: {predicted_fat_mass:.2f} kg (Expected: {expected['fat_mass']:.2f} kg)\n")
        file.write(f"Predicted FFM: {predicted_ffm:.2f} kg (Expected: {expected['ffm']:.2f} kg)\n\n")
        file.write(f"Errors:\n")
        file.write(f"Weight Error: {weight_error:.2f}%\n")
        file.write(f"Fat Mass Error: {fat_mass_error:.2f}%\n")
        file.write(f"FFM Error: {ffm_error:.2f}%\n\n")
        file.write("=" * 50 + "\n\n")

print(f"Test completed. Results saved to {os.path.abspath(output_filename)}")

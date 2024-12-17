import base64
from datetime import datetime as dt
from flask import Flask, render_template, request, jsonify
from hall_model import calculate_energy_intake_for_target_weight, calculate_tee, simulate_hall_model
from plot_models import get_weight_loss_plot_image, get_energy_expenditure_plot_image

app = Flask(__name__, template_folder='templates')
MJ_TO_KCAL = 239.006
KG_TO_LBS = 2.20462
IN_TO_M = 0.0254

@app.route('/simulate', methods=['POST'])
def simulate():
    """
    Handle the simulation request and return results along with plot images.

    Input JSON:
        {
            "sex": "male" or "female",
            "age": int,
            "weight": float (in lbs),
            "height": float (in inches),
            "energy_intake": float (in kcal/day),
            "body_fat_percentage": float (in %),
            "duration": int (number of days)
            "date": str (date of simulation)
        }

    Returns JSON:
        {
            "results": [...],  # List of dictionaries for each day
            "weight_loss_plot": "data:image/png;base64,...",  # Weight loss plot as base64-encoded image
            "energy_expenditure_plot": "data:image/png;base64,..."  # Energy expenditure plot as base64-encoded image
        }
    """
    # Parse input data
    data = request.get_json()
    sex = data['sex'].lower().strip()
    age = data['age']
    weight = data['weight'] / KG_TO_LBS  # lbs -> kg
    height = data['height'] * IN_TO_M  # inches -> meters
    pal_factor = data['pal_factor']
    body_fat_percentage = data['body_fat_percentage']
    if (body_fat_percentage is not None and body_fat_percentage > 0):
        body_fat_percentage /= 100

    if "energy_intake" in data and data["energy_intake"]:
        # Energy Intake Mode
        energy_intake = data['energy_intake'] / MJ_TO_KCAL
        duration = data['duration']
        baseline_ci = 0.5 * data['energy_intake'] / 4

        results = simulate_hall_model(duration, sex, age, weight, height, energy_intake, baseline_ci, energy_intake, body_fat_percentage, pal_factor)
        maintenance_message = ""
    else:
        # Target Weight Mode
        target_weight = data['target_weight'] / 2.20462  # lbs -> kg
        start_date = dt.strptime(data['date'], "%Y-%m-%d")
        target_date = dt.strptime(data['target_date'], "%Y-%m-%d")
        duration = (target_date - start_date).days
        baseline_ei = calculate_tee(weight, age, sex, 10.0, 0, pal_factor) # estimate of energy intake with 10 MJ/day EI assumed for TEF
        baseline_ci = 0.5 * baseline_ei / 4 # 50% of baseline energy intake for carbohydrate intake

        results, required_energy_intake, maintenance_calories = calculate_energy_intake_for_target_weight(
            duration, target_weight, sex, age, weight, height, baseline_ci, baseline_ei, body_fat_percentage, pal_factor
        )

        maintenance_message = f"Required energy intake of {required_energy_intake:.2f} to reach {data['target_weight']:.2f} lbs by {data['target_date']} and then {maintenance_calories:.2f} kcal/day to maintain new weight."

    # Generate plots
    weight_loss_plot_buffer = get_weight_loss_plot_image(results)
    energy_expenditure_plot_buffer = get_energy_expenditure_plot_image(results)

    # Prepare response
    response = {
        "results": results,
        "weight_loss_plot": f"data:image/png;base64,{base64.b64encode(weight_loss_plot_buffer).decode('utf-8')}",
        "energy_expenditure_plot": f"data:image/png;base64,{base64.b64encode(energy_expenditure_plot_buffer).decode('utf-8')}",
        "maintenance_message": maintenance_message
    }
    print(maintenance_message)

    return jsonify(response)

@app.route("/")
def index():
    return render_template("index.html")

@app.errorhandler(404)
def page_not_found(e):
    return jsonify({"error": "Route not found"}), 404

if __name__ == "__main__":
    app.run(debug=True)

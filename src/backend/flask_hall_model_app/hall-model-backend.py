import base64
from flask import Flask, render_template, request, jsonify
from hall_model import simulate_hall_model, calculate_initial_fat_mass, calculate_initial_lean_mass, calculate_tee
from plot_models import get_weight_loss_plot_image, get_energy_expenditure_plot_image

app = Flask(__name__, template_folder='templates')

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
    weight = data['weight'] / 2.20462  # Convert lbs to kg
    height = data['height'] * 0.0254 # Convert inches to m
    energy_intake = data['energy_intake'] / 239.006  # Convert kcal/day to MJ/day
    body_fat_percentage = data['body_fat_percentage']  # Convert % to fraction
    duration = data['duration']
    baseline_ci = .50 * data['energy_intake'] / 4 # 50% of energy intake, at 4 g/kcal
    fat_mass = None
    if (body_fat_percentage is not None and body_fat_percentage > 0):
        fat_mass = weight * body_fat_percentage / 100
    else:
        fat_mass = calculate_initial_fat_mass(sex, age, weight, height)
    lean_mass = calculate_initial_lean_mass(weight, fat_mass)
    tee = calculate_tee(weight, age, sex, energy_intake)

    # Run simulation using the Hall model
    # def simulate_hall_model(duration_days, body_weight, height, energy_intake, baseline_ci, baseline_ei):
    results = simulate_hall_model(duration, sex, age, weight, height, energy_intake, baseline_ci, tee)

    # Generate plots
    weight_loss_plot_buffer = get_weight_loss_plot_image(results)
    energy_expenditure_plot_buffer = get_energy_expenditure_plot_image(results)

    # Prepare response
    response = {
        "results": results,
        "weight_loss_plot": f"data:image/png;base64,{base64.b64encode(weight_loss_plot_buffer).decode('utf-8')}",
        "energy_expenditure_plot": f"data:image/png;base64,{base64.b64encode(energy_expenditure_plot_buffer).decode('utf-8')}",
    }

    return jsonify(response)

@app.route("/")
def index():
    return render_template("index.html")

@app.errorhandler(404)
def page_not_found(e):
    return jsonify({"error": "Route not found"}), 404

if __name__ == "__main__":
    app.run(debug=True)

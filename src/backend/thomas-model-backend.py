import base64
from flask import Flask, render_template, request, jsonify
from thomas_model_test import run_simulation, get_weight_loss_plot_image, get_energy_expenditure_plot_image

app = Flask(__name__ , template_folder='templates')

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
            "duration": int (number of days)
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
    sex = data['sex']
    age = data['age']
    weight = data['weight'] / 2.20462  # Convert lbs to kg
    height = data['height'] * 2.54  # Convert inches to cm
    energy_intake = data['energy_intake']
    duration = data['duration']

    # Run simulation
    results = run_simulation(sex, age, weight, height, energy_intake, duration)

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
    print("route/: should return index.html")
    return render_template("index.html")


if __name__ == "__main__":
    app.run(debug=True)

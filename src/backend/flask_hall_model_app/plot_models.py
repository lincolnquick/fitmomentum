import matplotlib.pyplot as plt
import matplotlib
import mplcursors
import io

# Constants for unit conversions
CONVERSION_FACTOR = 2.20462  # kilograms to pounds

# Plotting Functions

def create_weight_loss_plot(results, model_name="Weight Loss Model"):
    """
    Generate the weight loss plot (weight, fat mass, and lean mass) over time.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, ...}]
        model_name (str): Name of the model for plot title.
    """
    matplotlib.use('Agg')
    days = [res['day'] for res in results]
    weights = [res['weight'] * CONVERSION_FACTOR for res in results]
    fat_mass = [res['fat_mass'] * CONVERSION_FACTOR for res in results]
    lean_mass = [res['lean_mass'] * CONVERSION_FACTOR for res in results]

    plt.figure(figsize=(10, 6))
    weight_line, = plt.plot(days, weights, label='Total Weight (lbs)', linewidth=2)
    fat_mass_line, = plt.plot(days, fat_mass, label='Fat Mass (lbs)', linewidth=2, linestyle='--')
    lean_mass_line, = plt.plot(days, lean_mass, label='Lean Mass (lbs)', linewidth=2, linestyle=':')
    plt.title(f'{model_name} - Weight, Fat Mass, and Lean Mass Over Time', fontsize=16)
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
    Generate the plot and save it to a file.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, ...}]
        model_name (str): Name of the model for plot title.
        filename (str): Filename to save the plot.
    """
    create_weight_loss_plot(results)
    image_buffer = io.BytesIO()
    plt.savefig(image_buffer, format='png')
    image_buffer.seek(0)
    plt.close()
    return image_buffer

def create_energy_expenditure_plot(results, model_name="Energy Expenditure Model"):
    """
    Generate the energy expenditure plot (TEE, RMR, DIT, SPA, PA) over time.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
        model_name (str): Name of the model for plot title.
    """
    matplotlib.use('Agg')
    days = [res['day'] for res in results]
    tee = [res['tee'] for res in results]
    rmr = [res['rmr'] for res in results]
    tef = [res['tef'] for res in results]
    pa =  [res['pa'] for res in results]

    plt.figure(figsize=(10, 6))
    tee_line, = plt.plot(days, tee, label='Total Energy Expenditure (TEE)', linewidth=2)
    rmr_line, = plt.plot(days, rmr, label='Resting Metabolic Rate (RMR)', linewidth=2, linestyle='--')
    tef_line, = plt.plot(days, tef, label='Thermic Effect of Food (TEF)', linewidth=2, linestyle=':')
    pa_line, = plt.plot(days, pa, label='Physical Activity (PA)', linewidth=2, linestyle=':')

    plt.title(f'{model_name} - Energy Expenditure Components Over Time', fontsize=16)
    plt.xlabel('Days', fontsize=14)
    plt.ylabel('Energy (kcal/day)', fontsize=14)
    plt.legend()
    plt.grid(True)

    # Add interactive hover for local display
    cursor = mplcursors.cursor([tee_line, rmr_line, tef_line, pa_line], hover=True)
    cursor.connect(
        "add",
        lambda sel: sel.annotation.set_text(
            f"Day: {days[int(sel.target[0])]}, Value: {sel.target[1]:.2f}"
        )
    )

def get_weight_loss_plot_image(results):
    """
    Generate the weight loss plot and return the image buffer.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, ...}]

    Returns:
        io.BytesIO: Image buffer for the weight loss plot.
    """
    image_buffer = save_weight_loss_plot(results)
    return image_buffer.getvalue()

def get_energy_expenditure_plot_image(results):
    """
    Generate the energy expenditure plot and return the image buffer.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]

    Returns:
        io.BytesIO: Image buffer for the energy expenditure plot.
    """
    image_buffer = save_energy_expenditure_plot(results)
    return image_buffer.getvalue()


def save_energy_expenditure_plot(results):
    """
    Generate the energy expenditure plot and save it to a file.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
        model_name (str): Name of the model for plot title.
        filename (str): Filename to save the plot.
    """
    create_energy_expenditure_plot(results)
    image_buffer = io.BytesIO()
    plt.savefig(image_buffer, format='png')
    image_buffer.seek(0)
    plt.close()
    return image_buffer

def plot_weight_loss_display(results, model_name="Weight Loss Model"):
    """
    Generate and display the weight loss plot locally.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, ...}]
        model_name (str): Name of the model for plot title.
    """
    create_weight_loss_plot(results, model_name=model_name)
    plt.show()

def plot_energy_expenditure_display(results, model_name="Energy Expenditure Model"):
    """
    Generate and display the energy expenditure plot locally.

    Parameters:
        results (list): A list of dictionaries containing the results of the simulation for
        each day. [{day, weight, fat_mass, lean_mass, tee, rmr, dit, spa, pa}]
        model_name (str): Name of the model for plot title.
    """
    create_energy_expenditure_plot(results, model_name=model_name)
    plt.show()

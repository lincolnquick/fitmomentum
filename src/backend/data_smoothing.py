import numpy as np
from scipy.signal import savgol_filter

def dynamic_savgol_filter(data):
    """
    Dynamically apply Savitzky-Golay filter with calculated window size and polynomial order.
    
    Parameters:
        data (list or np.array): Input data sequence.
    
    Returns:
        np.array: Smoothed data sequence.
    """
    n = len(data)
    if n < 30 or n > 1000:
        raise ValueError("Dataset size must be between 30 and 1000.")
    
    # Calculate window size (must be odd, around 5% of the dataset size, capped at 101)
    window_size = min(max(5, (n // 20) | 1), 101)
    
    # Polynomial order (fixed at 2 for weight data)
    poly_order = 2
    
    # Ensure window size > poly_order
    if window_size <= poly_order:
        raise ValueError("Window size must be greater than polynomial order.")
    
    # Apply Savitzky-Golay filter
    smoothed_data = savgol_filter(data, window_size, poly_order)
    return smoothed_data

# Example usage
np.random.seed(42)
example_data = np.random.normal(70, 0.5, 500)  # Simulate 500 weight measurements with noise
smoothed_data = dynamic_savgol_filter(example_data)

print("Original Data (first 10):", example_data[:10])
print("Smoothed Data (first 10):", smoothed_data[:10])

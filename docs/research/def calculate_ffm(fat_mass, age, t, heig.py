def calculate_ffm(fat_mass, age, t, height, sex):
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

if __name__ == "__main__":
    print(calculate_ffm(25, 36, 6, 170, "male"))
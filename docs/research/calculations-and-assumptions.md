# Calculations and Assumptions for FitMomentum
## 1. Caloric Deficit and Weight Loss
### How is a calorie deficit related to fat loss?
A calorie deficit of approximately 3,500 calories is commonly associated with the loss of 1 pound of fat. This is based on the energy content of adipose tissue, though individual factors such as metabolism and activity level can affect accuracy.  
*Formula:*  
> Weight Change (lbs) = Total Calorie Deficit / 3,500  
> 3,500 kcal deficit → 1 lb weight loss or 7,700 kcal deficit → 1 kg weight loss  
*(Wishnofsky, 1958)*

**References:**  
- Wishnofsky, M. (1958). Caloric equivalents of gained or lost weight. *The American Journal of Clinical Nutrition.* [https://www.sciencedirect.com/science/article/abs/pii/S0002916523151082?via%3Dihub]

---

## 2. Inaccuracies of the Wishnofsky Model
### Why is the Wishnofsky Model inaccurate?
While the Wishnofsky Model is a simple and widely cited "rule of thumb" in nutrition, it oversimplifies the complex dynamics of weight loss. According to modern research, including the study by Thomas et al. (2014), the model's assumptions are flawed:

1. **Energy Content of Weight Change Varies:**
   - Weight loss is not always derived primarily from fat stores, particularly during the early phases of dieting when glycogen, protein, and water are also lost.
   - The energy content of weight change is lower than 3,500 kcal/lb during early dieting and may increase over time as fat becomes the primary energy source.

2. **Metabolic Adaptations Occur:**
   - Resting energy expenditure (REE) decreases with weight loss due to reductions in body mass and adaptive thermogenesis.
   - Non-exercise activity thermogenesis (NEAT) and the thermic effect of food (TEF) also decrease, further slowing weight loss.

3. **Dynamic Phases of Weight Loss:**
   - **Early Phase:** Rapid initial weight loss due to glycogen and water depletion.
   - **Later Phase:** Slower, fat-dominated weight loss as metabolic adaptations reduce energy expenditure.

4. **Weight Loss Plateaus:**
   - As energy intake decreases, energy expenditure adjusts downward until a new equilibrium is reached, causing weight loss to plateau.

### Practical Context: Why the Wishnofsky Model is Still Helpful
Despite its inaccuracies, the Wishnofsky Model serves as a helpful **rule of thumb** for:
- Setting initial weight loss expectations for short-term diets.
- Simplifying complex energy balance principles for general audiences.
- Offering a starting point for calorie deficit calculations in apps like FitMomentum.

### How can FitMomentum apply this knowledge?
- Clearly communicate the limitations of the 3,500 kcal/lb rule in the app's informational resources.
- Use dynamic prediction models (e.g., Thomas Model) for more accurate long-term weight loss projections.
- Incorporate messages explaining why weight loss slows over time, especially when users encounter plateaus.

**References:**  
- Thomas, D. M., Gonzalez, M. C., Pereira, A. Z., Redman, L. M., & Heymsfield, S. B. (2014). Time to Correctly Predict the Amount of Weight Loss with Dieting. *Journal of the Academy of Nutrition and Dietetics, 114*(6), 857–861. [https://doi.org/10.1016/j.jand.2014.02.003]

---

## 3. Body Mass Index (BMI)
### How do you calculate BMI?
BMI is calculated by dividing a person’s weight in kilograms by the square of their height in meters.  
*Formula:*  
> BMI = W / H^2  
> Where:  
> W = Weight in kg  
> H = Height in meters  

**References:**  
- World Health Organization. (2005). *The SURF Report 2* [Report]. [https://iris.who.int/bitstream/handle/10665/43190/9241593024_eng.pdf]

---

## 4. Basal Metabolic Rate (BMR)
### How is BMR calculated?
The Mifflin-St Jeor Equation is one of the most reliable methods:  
*Formula:*  
> BMR = 10 * W + 6.25 * H - 5 * A + S  
> Where:  
> W = Weight in kg  
> H = Height in cm  
> A = Age in years  
> S = +5 for males, -161 for females  

*(Mifflin et al., 1990)*

**References:**  
- Mifflin, M., St Jeor, S., Hill, L., Scott, B., Daugherty, S., & Koh, Y. (1990). A new predictive equation for resting energy expenditure in healthy individuals. *American Journal of Clinical Nutrition, 51*(2), 241–247. [https://doi.org/10.1093/ajcn/51.2.241]


---

## 5. Thomas Model for Predicting Weight Change
### What is the Thomas model?
The Thomas model is a dynamic formula used to predict changes in body composition (fat mass and fat-free mass) over time in adults. Unlike the static 3,500-calorie rule, this model accounts for physiological factors such as sex, age, height, and metabolic adaptations. The equations provide separate predictions for men and women, considering changes in fat mass, fat-free mass, and metabolic rate.

### Equations
#### Females:
\[
FFM(t) = -72.1 + 2.5F(t) - 0.04(A_0 + t/365) + 0.7H - 0.002F(t)(A_0 + t/365) - 0.01F(t)H - 0.04F(t)^2 + 0.0003F(t)^2(A_0 + t/365) + 0.0000004F(t)^4 + 0.0002F(t)^3 + 0.0003F(t)^2H - 0.000002F(t)^3H
\]

#### Males:
\[
FFM(t) = -71.7 + 3.6F(t) - 0.04(A_0 + t/365) + 0.7H - 0.002F(t)(A_0 + t/365) - 0.01F(t)H + 0.00003F(t)^2(A_0 + t/365) - 0.07F(t)^2 + 0.0006F(t)^3 - 0.000002F(t)^4 + 0.0003F(t)^2H - 0.000002F(t)^3H
\]

### Terms and Variables
- \(FFM(t)\): Fat-free mass (kg) at time \(t\) (in days).
- \(F(t)\): Fat mass (kg) at time \(t\).
- \(H\): Height (cm).
- \(A_0\): Baseline age (years).
- \(t\): Time (days) since the start of the weight change period.

### Key Features
- The model separates fat mass (\(F(t)\)) and fat-free mass (\(FFM(t)\)), offering more precise predictions of body composition.
- It accounts for age-related and height-related differences in weight change.
- The dynamic nature of the model allows for realistic, time-dependent weight predictions.

**References:**  
- Thomas, D. M., Martin, C. K., Heymsfield, S., Redman, L. M., Schoeller, D. A., & Levine, J. A. (2011). A simple model predicting individual weight change in humans. *Journal of Biological Dynamics, 5*(6), 579–599. [https://doi.org/10.1080/17513758.2010.508541]

---

## 6. Energy Balance Principle
### How is energy balance calculated?
The Energy Balance Principle is defined as:
\[
R = I - E
\]
Where:  
- \(R\): Rate of weight change (caloric balance, kcal/day).  
- \(I\): Caloric intake (kcal/day).  
- \(E\): Caloric expenditure (kcal/day).  

This principle demonstrates that weight loss occurs when energy expenditure exceeds energy intake.

**References:**  
- Fogler, H. (1986). *Elements of Chemical Reaction Engineering* (4th ed.). Prentice Hall.

---

## 7. Rate of Energy Expenditure
### What are the components of energy expenditure?
The rate of energy expenditure (\(E\)) is composed of four main factors:
\[
E = DIT + PA + RMR + SPA
\]
Where:  
- \(DIT\): Dietary-induced thermogenesis (kcal/day).  
- \(PA\): Volitional physical activity (kcal/day).  
- \(RMR\): Resting metabolic rate (kcal/day).  
- \(SPA\): Spontaneous physical activity (kcal/day).  

This equation breaks down energy expenditure into measurable components that can be adjusted to understand how changes in diet or activity affect total caloric burn.

### How can this be applied in FitMomentum?
- **Caloric Balance:** Display users' caloric balance using \(R = I - E\).  
- **Activity Breakdown:** Show a breakdown of caloric expenditure into \(DIT\), \(PA\), \(RMR\), and \(SPA\), helping users understand which areas contribute most to their energy use.  

**References:**  
- Gropper, S., Smith, J., & Groff, J. (2005). *Advanced Nutrition and Human Metabolism.* Thomson Wadsworth Publishing.

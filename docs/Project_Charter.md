# Project Charter: FitMomentum

## Purpose
This project aims to empower users on their weight loss journeys by providing enhanced visualizations and predictive modeling of health data from Apple Health. By combining accessible visual trends, motivational features, and actionable predictions, the app helps users stay informed and inspired to reach their goals.

---

## Objectives
- Develop and launch a modern iPhone app integrating Apple HealthKit for seamless data visualization and analysis, while supporting manual data entry for flexibility.
- Provide a freemium experience where basic features are free, with advanced features available via a paid subscription or one-time fee.
- Include an onboarding process and progress badges to ensure accessibility, motivation, and user engagement.
- Create exportable data options (e.g., PDFs, Excel spreadsheets) and a customizable visualization experience with a "dark mode."

---

## Scope
### In-Scope for Initial Release:
1. Visualizations for key metrics (weight, body fat %, calories, steps, METs).
2. Predictive modeling of weight loss trends, goal projections, and milestone tracking.
3. Integration with Apple HealthKit, with options for manual data entry and saving back to HealthKit.
4. Onboarding process with tutorials and motivational badges/reminders.
5. Unit conversions for key metrics (e.g., pounds, stones, kilograms).
6. Compatibility with iOS 18 and iPads supporting HealthKit.
7. A tabbed navigation design following Apple’s Human Interface Guidelines.
8. Safeguards against unrealistic or unsafe recommendations based on health guidelines.

### Out-of-Scope for Initial Release:
1. Advanced machine learning or AI-driven features.
2. Multi-language support (future consideration).
3. Website development (scheduled for after app completion but before release).
4. Non-health-related features.
5. Exportable data options (may be included post-launch, depending on time constraints).

---

## Deliverables
1. An iPhone and iPad-compatible app adhering to Apple's Human Interface Guidelines.
2. Freemium monetization model with clear differentiation between free and premium features.
3. A promotional website to showcase app features and provide help documentation.
4. A GitHub repository with:
   - Project documentation (e.g., Scope, Requirements, Design, etc.).
   - Source code for the app.

---

## Constraints
- Development will rely primarily on Apple HealthKit but support manual data entry with appropriate warnings for error-prone data types.
- Limited to English for the initial release.
- Solo development with 20-40 hours per week allocated to the project.
- Must pass Apple's App Store review process for publication.
- Compatibility with iOS 18 and later.

---

## Assumptions
- Users will own HealthKit-enabled devices (e.g., iPhone, iPad, Apple Watch, Bluetooth scale).
- Users consistently log accurate information using these devices, including height, weight, body fat percentage, daily caloric intake, and activity tracking.
- Users will consent to share health data with the app through HealthKit.
- The app will use only publicly available health calculations for accuracy.
- Predictive features will rely on modifiable assumptions for user flexibility.

---

## Success Criteria
1. App Store publication within one year after development completion and Apple's review process.
2. Download metrics and App Store ratings (target: 4+ stars).
3. Premium user conversion rate and total revenue generated.
4. A GitHub repository showcasing the project’s source code and documentation as a portfolio piece.
5. Feedback from beta testing and early adopters validates usability and functionality.

---

## Stakeholders
- **Primary Developer:** Lincoln Quick.
- **End Users:** Adults in the US and Canada on weight loss journeys.

---

## Testing and Quality Assurance
- Testing on iPhone and iPad to ensure functionality across devices.
- Beta testing through TestFlight to gather feedback from early adopters before App Store submission.

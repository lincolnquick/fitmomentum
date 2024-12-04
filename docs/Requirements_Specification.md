# Requirements Specification: FitMomentum

## 1. Functional Requirements

### Core Features
1. **Data Visualization:**
   - Display key metrics (e.g., weight, body fat %, calories burned/consumed) using line graphs.
   - Allow overlapping (compounded) graphs to show up to 2-3 metrics on the same time axis.
   - Use smoothing for metrics like weight to account for normal fluctuations.
   - Enable interactive data points that users can tap to view the exact value for a specific date.
   - Incorporate colors and shading to indicate progress:
     - **Green shading:** Indicates weight loss, proportional to the amount lost.
     - **Red shading:** Indicates weight gain.
   - Allow users to customize graph colors, metric combinations, and shading preferences.
   - Provide default time intervals for viewing data: 7 days, 30 days, 90 days, 180 days, and 1 year, with an option for custom intervals.

2. **Goal Setting:**
   - Enable users to set weight loss targets.
   - Provide feasible target recommendations (e.g., -1 lb/week or -2 lbs/week).
   - Recommend caloric intake and macronutrient distribution (protein, carbs, fats) based on user preferences:
     - Offer 3 options: **high-protein**, **low-carb**, and **balanced**.
     - Use available data (e.g., past weight measurements, body fat %, caloric intake, macronutrients, and activity levels) for recommendations.
   - Calculate and display **Total Daily Energy Expenditure (TDEE)** using:
     - HealthKit activity levels (adjusted for overestimation bias).
     - User-defined activity level options (e.g., sedentary, moderately active).
     - Weight and caloric intake data for more precise estimations.
   - Allow users to adjust milestones incrementally (e.g., by weight or percentage of total target).

3. **Predictive Analytics:**
   - Graph projected weight trends with user-defined parameters.
   - Display estimated goal and milestone completion dates.
   - Provide numeric predictions for user-selectable intervals (e.g., 7, 30, 90, 180 days).

4. **Basic Health Calculations:**
   - Calculate and display:
     - BMI (Body Mass Index).
     - BMR (Basal Metabolic Rate).
     - TDEE (with multiple calculation methods as outlined above).
   - Ensure all calculations are based on peer-reviewed scientific literature.
   - Dynamically update calculations as user data (e.g., weight, activity levels) changes.

5. **Manual Data Entry:**
   - Allow users to manually enter weight and body fat % data daily or historically.
   - Store manual entries in CloudKit rather than HealthKit for the initial release.
   - Enable users to edit or delete manually entered data while preventing direct edits to HealthKit-provided data.

6. **Security and Privacy:**
   - Allow users to secure the app with a PIN, FaceID, or TouchID.
   - Warn users if goals fall outside recommended health guidelines (e.g., weight loss > 2 lbs/week).
   - Avoid storing sensitive health data outside of HealthKit or the user's iCloud.

---

## 2. Non-Functional Requirements

### Usability
- The app must:
  - Be intuitive for users familiar with apps like Apple Health and MyFitnessPal.
  - Include subtle animations for a fluid user experience without being distracting.

### Performance
- The app must:
  - Load data and display graphs in under 2 seconds.
  - Handle at least 1 year of historical HealthKit data efficiently.

### Compatibility
- The app must:
  - Support iOS 18 and later.
  - Be optimized for iPhones and iPads.

### Security
- The app must:
  - Encrypt stored preferences, milestones, and manually entered data.
  - Ensure all sensitive data remains private and accessible only to the user.

---

## 3. System Requirements

### Platforms and Devices
- **Platforms:** iOS 18+
- **Devices:** iPhone and iPad

### Dependencies
- **Frameworks:**
  - Apple HealthKit
  - SwiftUI
  - Optional: Third-party graphing library (e.g., Charts)

### Data Persistence
- Store user preferences and milestones locally and optionally sync to iCloud.
- Use HealthKit as the primary data source, with manual entries stored in CloudKit.

---

## 4. User Stories

1. **Setting Goals:**
   - *As a user, I want to set a weight loss goal and milestones so I can track my progress toward my desired weight.*

2. **Viewing Progress:**
   - *As a user, I want to see trends in my weight and calories over time so I can understand my progress.*

3. **Predicting Outcomes:**
   - *As a user, I want to see estimated dates for goal completion so I can stay motivated.*

4. **Customizing Preferences:**
   - *As a user, I want to choose my preferred units of measurement and adjust assumptions for predictions so the app aligns with my needs.*

5. **Securing Data:**
   - *As a user, I want to secure my app with FaceID or a PIN so my data remains private.*

6. **Citing Calculations:**
   - *As a user, I want to understand the source of calculations so I can trust the app’s recommendations.*

---

## 5. Assumptions and Constraints

### Assumptions
- Users will enable HealthKit permissions for the app.
- Users provide accurate and consistent data for better predictions.

### Constraints
- The app must not store sensitive health data outside HealthKit or CloudKit.
- The project must be completed within a 1-year timeline.

---

## 6. Success Metrics

1. **Initial Success:**
   - The app is published on the Apple App Store.
   - The app meets Apple’s design and functionality standards.

2. **Post-Launch Metrics:**
   - Number of downloads and active users.
   - User feedback via App Store reviews (target: 4+ stars).
   - Premium feature adoption rate (conversion to paid users).

3. **Feedback:**
   - User reviews on the App Store.
   - Direct links to studies and methods on the support website.

---

## 7. Risks

1. **Development Challenges:**
   - Limited iOS development experience.
   - Potential delays in learning SwiftUI and HealthKit.

2. **App Store Approval:**
   - Strict guidelines may require multiple submission attempts.

3. **Time Constraints:**
   - Completing the project as a solo developer within 1 year.

---

## 8. Future Considerations
- Multi-language support.
- Social sharing of milestones and achievements.
- Advanced machine learning models for improved predictions.

---

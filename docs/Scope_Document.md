# Scope Document: FitMomentum

## Project Overview
**FitMomentum** is an iPhone app designed to empower users on their weight loss journeys by providing visualizations, trend predictions, and goal-setting features using Apple HealthKit. The app aims to offer intuitive insights while maintaining privacy and data security.

---

## In-Scope Features
For the initial release, the app will include the following **Minimum Viable Product (MVP)** features:
1. **Data Visualization:**
   - Visualize weight, body fat %, calories burned, and calories consumed using HealthKit data.
   - Display trends over time with intuitive graphs.

2. **Goal Setting and Recommendations:**
   - Allow users to set weight loss targets.
   - Provide feasible target recommendations (e.g., -1 lb/week or -2 lbs/week).

3. **Basic Analysis:**
   - Calculate BMI, BMR, and "ideal" weight based on age, sex, and height.
   - Generate milestones for weight loss targets.
   - Allow users to modify milestones by percentage or weight increments.

4. **Predictive Analytics:**
   - Graph trends to estimate goal and milestone completion dates.
   - Allow users to modify assumptions in predictive models for more personalized insights.

5. **User Interface:**
   - Include subtle animations for a fluid, pleasant user experience.
   - Use a tabbed navigation layout consistent with Apple’s design guidelines.

---

## Out-of-Scope Features (for Initial Release)
The following features may be added post-launch:
1. **Motivational Elements:**
   - Achievements or badge systems.
   - Export options for PDFs or Excel spreadsheets.

2. **Data Analysis Enhancements:**
   - Analyze the accuracy of Apple’s Active and Rest Calories metrics based on input data.

3. **Additional Data Entry Options:**
   - Enable manual entry of data (e.g., activity from Apple Watch, metrics from Withings, or MyFitnessPal calorie logs).

4. **Advanced UI/UX:**
   - Onboarding tutorials for new users.

5. **Cloud Integration:**
   - Saving app preferences or milestones to iCloud.

---

## Technical Scope
1. **Third-Party Tools and Libraries:**
   - Use Apple HealthKit for data integration.
   - Explore lightweight libraries for graphing and statistical modeling if needed.

2. **Offline Functionality:**
   - Core features should work offline, except for viewing online support documents.

3. **Data Persistence:**
   - Health data is stored in Apple HealthKit.
   - User milestones, preferences, and app settings are stored locally on the device and optionally in the user's iCloud.

4. **Security and Privacy:**
   - No remote servers will store user health data.
   - App preferences and milestones will use encryption to ensure secure storage.
   - Users can lock the app with PIN, FaceID, or TouchID for additional privacy.

5. **Regulations:**
   - Regulatory requirements, including GDPR and HIPAA compliance, will be explored and implemented as needed.

---

## Constraints
1. **Development:**
   - Limited to a one-year timeline.
   - Solo development project with 20-40 hours per week allocated.

2. **Budget:**
   - Limited expenses, including domain and hosting costs and Apple Developer Program membership.

3. **Compatibility:**
   - Supports iPhones and iPads running iOS 18 or later.

---

## Assumptions
1. Users will:
   - Own HealthKit-enabled devices (e.g., iPhone, Apple Watch, Bluetooth scale).
   - Be familiar with apps like MyFitnessPal and Apple Health.

2. All HealthKit data is accurate and provided by other apps or devices.

3. App preferences and user-generated targets will sync to iCloud if possible.

4. Predictive modeling will use simple, publicly available statistical methods.

---

## Risks
1. **Skill and Experience:**
   - Limited iOS development experience may slow implementation.

2. **Timeline:**
   - Developing the app within one year as a solo project is challenging.

3. **App Store Approval:**
   - Apple's review process may delay publication.

4. **Budget Constraints:**
   - The project is self-funded with minimal expenses planned.

---

## Success Metrics
1. Initial Success:
   - Completion and publication of the app on the Apple App Store.

2. Post-Launch Metrics:
   - Number of downloads.
   - User review scores (target: 4+ stars).
   - Conversion rate for premium features.
   - Total revenue from premium subscriptions or one-time fees.

3. Feedback:
   - User reviews on the App Store.
   - Potential social media presence for user engagement and support.

---

## Milestones and Timeline
1. **Planning (Month 1):**
   - Finalize project charter and scope document.
   - Explore HealthKit capabilities.

2. **Design and Prototyping (Month 1-2):**
   - Create wireframes for key screens.
   - Develop visual design and navigation flows.

3. **Development (Month 3-9):**
   - Implement core features (data visualization, goal setting, predictions).
   - Test offline functionality and local storage.

4. **Testing and Iteration (Month 10-11):**
   - Conduct beta testing with TestFlight.
   - Address user feedback and refine features.

5. **Launch (Month 12):**
   - Submit to the App Store.
   - Publish the app and the promotional website.


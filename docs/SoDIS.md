# Software Development Impact Statement (SoDIS): FitMomentum

## 1. Project Overview
**FitMomentum** is an iPhone app designed to assist users on their weight loss journeys through enhanced data visualization, goal setting, predictive modeling, and motivational features. It integrates with Apple's HealthKit for seamless access to health data while maintaining strict user privacy.

This app is a solo portfolio project developed by Lincoln Quick, with insights drawn from personal experiences, peer-reviewed scientific research, and beta testing among friends and family.

---

## 2. Stakeholders

### Primary Stakeholders
- **End Users**: Individuals in the United States on a weight loss journey, primarily those who own an iPhone, optionally an Apple Watch, and a Bluetooth-enabled scale compatible with HealthKit.
- **Healthcare Professionals**: While not intended as a clinical tool, professionals may encounter the app through their patients.

### Secondary Stakeholders
- **Apple Inc.**: Provider of HealthKit, iCloud, and App Store infrastructure.
- **Beta Testers**: Family members and friends testing the app prior to release.
- **Scientific Community**: Source of peer-reviewed research for calculations and recommendations.

### Tertiary Stakeholders
- **Fitness and Health Enthusiasts**: Users seeking better tracking and visualization tools.
- **Developers and Open-Source Community**: Beneficiaries of the project's documentation and code on GitHub.

---

## 3. Ethical Concerns and Risks

### 3.1 Biases in Solo Development
- **Concern**: As a solo project, the app may reflect personal biases and lack rigorous peer review.
- **Mitigation**: Conduct beta testing with diverse users, solicit feedback, and transparently document research sources, calculations, and assumptions in the GitHub repository and user-facing website.

### 3.2 Inclusivity in Calculations
- **Concern**: Existing models for TDEE, RMR/BMR, and weight loss predictions primarily account for biological sex and exclude trans, non-binary individuals, and racial variations.
- **Mitigation**:
  - Explicitly acknowledge these limitations within the app.
  - Clearly communicate that current calculations are based on available research and encourage further scientific exploration to improve inclusivity.
  - Offer users control to manually adjust assumptions for personalization.

### 3.3 Psychological Impact
- **Concern**: The app's motivational features and weight tracking may inadvertently contribute to obsessive behaviors, body dysmorphia, or eating disorders.
- **Mitigation**:
  - Include clear warnings and disclaimers, encouraging users to consult healthcare professionals before relying solely on the app.
  - Avoid promoting extreme or unsafe weight loss goals (e.g., >2 lbs/week) and incorporate safeguards for healthy recommendations.
  - Provide educational content on sustainable weight loss and psychological well-being.

### 3.4 Accuracy of Recommendations
- **Concern**: Implementations of scientific models (e.g., Wishnofsky, Hall, Heymsfield) may contain errors or misrepresent findings, leading to inaccurate recommendations.
- **Mitigation**:
  - Thoroughly test all calculations against known benchmarks.
  - Transparently document all equations, research sources, and implementation details for peer review.
  - Provide disclaimers emphasizing that the app is not a substitute for medical advice.

### 3.5 Data Privacy and Security
- **Concern**: Health data is sensitive, and any compromise could harm user privacy.
- **Mitigation**:
  - The app will not transmit or process user health data outside the device, HealthKit, or iCloud.
  - Ensure all local data is encrypted and protected with Apple's native security mechanisms (e.g., FaceID, PIN).
  - Exclude user health data from bug reports and crash logs.
  - Confirm that HIPAA does not apply under current usage assumptions but maintain compliance with relevant privacy laws (e.g., GDPR).

### 3.6 Overreliance on Technology
- **Concern**: Users may depend heavily on the app's predictions and recommendations without consulting qualified professionals.
- **Mitigation**:
  - Include disclaimers advising users to consult healthcare professionals.
  - Educate users on the limitations of predictions and encourage a balanced approach to weight loss.

---

## 4. Ethical Safeguards and Documentation

1. **Transparency**:
   - All underlying calculations, assumptions, and limitations will be documented in a public GitHub repository and user-facing website.
   - Sources for scientific research will be cited in the app's educational materials.

2. **Warnings and Disclaimers**:
   - Prominently display disclaimers regarding the app's limitations, especially for predictions and health calculations.
   - Warn against unsafe weight loss goals and encourage consultation with medical professionals.

3. **Data Protection**:
   - Adhere strictly to Apple's security and privacy guidelines for HealthKit data.
   - Limit data storage to on-device and user-controlled iCloud storage.

4. **Inclusivity and Control**:
   - Allow users to customize inputs and assumptions for personalized results.
   - Acknowledge limitations in existing scientific models regarding sex, gender, and race inclusivity.

5. **Education**:
   - Provide resources on sustainable weight loss, addressing plateaus, and understanding energy balance.
   - Emphasize the psychological aspects of weight loss and the importance of self-care.

---

## 5. Potential Broader Impacts

### Positive Impacts
- **Motivation and Visualization**: Users gain improved tools for tracking progress, setting achievable goals, and staying motivated.
- **Education**: Provides users with accessible, science-based information to support sustainable weight loss.
- **Portfolio Contribution**: Demonstrates the developer's skills in ethical software design, health-related app development, and transparency.

### Negative Impacts
- **Exclusionary Models**: Current scientific models may exclude certain user demographics.
- **Unintended Psychological Effects**: May exacerbate unhealthy behaviors for some users.
- **Data Interpretation Risks**: Users may misinterpret app outputs as definitive advice.

---

## 6. Responsibility Matrix
| Ethical Concern                     | Mitigation Plan                                  | Responsible Party |
|-------------------------------------|-------------------------------------------------|------------------|
| Biases in Solo Development           | Beta testing, transparent documentation         | Lincoln Quick    |
| Inclusivity in Calculations          | Acknowledge limitations, user customization     | Lincoln Quick    |
| Psychological Impacts                | Warnings, healthy guidelines, educational content| Lincoln Quick    |
| Accuracy of Recommendations          | Thorough testing, transparent documentation     | Lincoln Quick    |
| Data Privacy and Security            | On-device storage, encryption, no external access| Lincoln Quick    |
| Overreliance on Technology           | Disclaimers, education, promote professional advice| Lincoln Quick    |

---

## 7. Conclusion
FitMomentum aims to empower users on their weight loss journeys by providing scientifically grounded tools for tracking, visualizing, and predicting progress. The app prioritizes data privacy, transparency, and user well-being while acknowledging limitations in current scientific models and solo development constraints. Ethical safeguards, including thorough documentation, warnings, and inclusivity considerations, ensure responsible software design and implementation.

---

## 8. References
- **Scientific Models**: Wishnofsky Rule, Hall Model, Heymsfield Model, Mifflin-St Jeor Equation.
- **Privacy Standards**: Apple's HealthKit and iCloud guidelines, GDPR.
- **User Guidelines**: Recommendations for sustainable weight loss and psychological well-being.

For further details, visit the user-facing [website](http://fitmomentumapp.com) upon release.


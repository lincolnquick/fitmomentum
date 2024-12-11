from graphviz import Digraph
import os

# Create a UML Class Diagram
uml_diagram = Digraph('UML_Class_Diagram', format='pdf')

# Set global node attributes to rectangle
uml_diagram.attr('node', shape='rectangle', fontsize='12', fontname='Helvetica', style='filled', fillcolor='lightgrey')


# Person class
uml_diagram.node('Person', '''Person
- dateOfBirth: Date
- sex: String
- height: Double
----------------------
+ getAgeAsFloat(): Float
+ getAgeAsInt(): Int
+ getAgeOnDate(date: Date): Int
''')

# Measurement class
uml_diagram.node('Measurement', '''Measurement
- timestamp: Date
----------------------
+ getTimestamp(): Date
''')

# Weight subclass
uml_diagram.node('Weight', '''Weight
- weight: Double
----------------------
+ getWeightInKg(): Double
+ getWeightInLbs(): Double
''')

# Nutrition subclass
uml_diagram.node('Nutrition', '''Nutrition
- calories: Double
- protein: Double
- carbs: Double
- fats: Double
----------------------
+ getCalories(): Double
+ getMacronutrientBreakdown(): String
''')

# Activity subclass
uml_diagram.node('Activity', '''Activity
- steps: Int
- distance: Double
----------------------
+ getSteps(): Int
+ getDistanceInKm(): Double
''')

# Prediction class
uml_diagram.node('Prediction', '''Prediction
- date: Date
- predictedWeight: Double
- predictedFatPercentage: Double
----------------------
+ getPredictionDetails(): String
''')

# Progress class
uml_diagram.node('Progress', '''Progress
- measurements: [Measurement]
----------------------
+ getMeasurementData(type: String): [Measurement]
+ filterByDateRange(start: Date, end: Date): [Measurement]
''')

# Services
uml_diagram.node('HealthKitService', '''HealthKitService
----------------------
+ fetchWeightData(): [Weight]
+ fetchNutritionData(): [Nutrition]
+ fetchActivityData(): [Activity]
+ fetchUserDetails(): Person
''')

uml_diagram.node('PredictionService', '''PredictionService
----------------------
+ generateWeightPrediction(person: Person, measurements: [Measurement]): Prediction
''')

uml_diagram.node('DataStorageService', '''DataStorageService
----------------------
+ saveData(data: Any)
+ fetchData(key: String): Any
''')

# ViewModels
uml_diagram.node('DashboardViewModel', '''DashboardViewModel
----------------------
+ getDashboardData(): [String: Any]
''')

uml_diagram.node('NutritionViewModel', '''NutritionViewModel
----------------------
+ getNutritionGraphData(): [Double]
+ getMacronutrientGoals(): String
''')

uml_diagram.node('TrendsViewModel', '''TrendsViewModel
----------------------
+ getTrendGraphData(): [Double]
+ getPredictionData(): Prediction
''')

uml_diagram.node('ProgressViewModel', '''ProgressViewModel
----------------------
+ getHistoricalData(type: String): [Measurement]
+ getGraphData(): [Double]
''')

uml_diagram.node('MoreViewModel', '''MoreViewModel
----------------------
+ getMenuOptions(): [String]
''')

# Add Relationships
uml_diagram.edge('Person', 'Measurement', label='1-*', dir='none')
uml_diagram.edge('Measurement', 'Weight', label='inherits', arrowhead='empty')
uml_diagram.edge('Measurement', 'Nutrition', label='inherits', arrowhead='empty')
uml_diagram.edge('Measurement', 'Activity', label='inherits', arrowhead='empty')
uml_diagram.edge('Measurement', 'Progress', label='aggregates', dir='both')
uml_diagram.edge('Prediction', 'Person', label='uses', dir='forward')
uml_diagram.edge('Prediction', 'Measurement', label='uses', dir='forward')
uml_diagram.edge('HealthKitService', 'Person', label='fetches', dir='forward')
uml_diagram.edge('HealthKitService', 'Measurement', label='fetches', dir='forward')
uml_diagram.edge('PredictionService', 'Prediction', label='creates', dir='forward')
uml_diagram.edge('DataStorageService', 'Person', label='stores', dir='forward')

uml_diagram.edge('DashboardViewModel', 'Measurement', label='uses', dir='forward')
uml_diagram.edge('NutritionViewModel', 'Nutrition', label='uses', dir='forward')
uml_diagram.edge('TrendsViewModel', 'Prediction', label='uses', dir='forward')
uml_diagram.edge('ProgressViewModel', 'Progress', label='uses', dir='forward')
uml_diagram.edge('MoreViewModel', 'DataStorageService', label='uses', dir='forward')

uml_diagram.attr(rankdir='LR', nodesep='1', ranksep='1')
uml_diagram.render('uml-class-diagram', directory='.', format='pdf', cleanup=False)

# Open the generated image
os.system('open uml-class-diagram.pdf')

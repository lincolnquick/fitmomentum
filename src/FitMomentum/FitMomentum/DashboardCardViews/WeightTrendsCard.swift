//
//  WeightTrendsCard.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/13/24.
//


import SwiftUI
import Charts

struct WeightTrendsCard: View {
    
    // Computed properties for scaling
    var weightRange: ClosedRange<Double> {
        let minWeight = recentWeightData.map { $0.weight }.min() ?? 0
        let maxWeight = recentWeightData.map { $0.weight }.max() ?? 1
        let padding = 0.5 // Add some space above and below for better visuals
        return (minWeight - padding)...(maxWeight + padding)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.gray.opacity(0.2))
            .frame(height: UIScreen.main.bounds.height / 3.5)
            .overlay(
                VStack(alignment: .leading, spacing: 10) {
                    // Card Title
                    Text("Recent Weight Trends")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top)

                    // Line Chart
                    Chart {
                        ForEach(recentWeightData) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(Color.blue)
                        }
                        
                        // Trend Line
                        RuleMark(y: .value("Average Weight", calculateTrendLine()))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundStyle(Color.green)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartYScale(domain: weightRange) // Auto-scale vertical axis
                    .padding()
                }
                .padding()
            )
    }

    func calculateTrendLine() -> Double {
        let weights = recentWeightData.map { $0.weight }
        return weights.reduce(0, +) / Double(weights.count) // Simple average for now
    }
}

struct WeightTrendsCard_Previews: PreviewProvider {
    static var previews: some View {
        WeightTrendsCard()
    }
}

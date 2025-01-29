import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            
            // Main Dashboard View
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            Text("Nutrition")
                .tabItem {
                    Label("Nutrition", systemImage: "leaf.fill")
                }

            Text("Predictions")
                .tabItem {
                    Label("Predictions", systemImage: "chart.bar.fill")
                }

            Text("Progress")
                .tabItem {
                    Label("Progress", systemImage: "flag.fill")
                }
            NavigationView {
                MoreMenu()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
        }
    }
}

struct DashboardView: View {
    var body: some View {
        VStack {
            // Header Section
            HStack {
                // Profile Picture
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("P")
                            .foregroundColor(.blue)
                            .font(.headline)
                    )

                Spacer()

                // Logo Placeholder
                Text("FitMomentum")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Spacer()

                // Settings Icon
                Image(systemName: "gearshape")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .safeAreaInset(edge: .top) { // Ensure the header respects safe areas
                Color.clear.frame(height: 0)
            }

            // Scrollable Content
            ScrollView {
                VStack(spacing: 20) {
                    // Recent Weight Trends Card
                    WeightTrendsCard()

                    // Weight Loss Progress Card
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: UIScreen.main.bounds.height / 3.5)
                        .overlay(
                            Text("Weight Loss Progress")
                                .font(.headline)
                                .foregroundColor(.blue)
                        )

                    // Daily Checklist Card
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: UIScreen.main.bounds.height / 3.5)
                        .overlay(
                            Text("Daily Checklist")
                                .font(.headline)
                                .foregroundColor(.blue)
                        )
                    
                    // Predictions Card
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: UIScreen.main.bounds.height / 3.5)
                        .overlay(
                            Text("Predictions")
                                .font(.headline)
                                .foregroundColor(.blue)
                        )
                    
                    // Recent Nutrition Trends Card
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: UIScreen.main.bounds.height / 3.5)
                        .overlay(
                            Text("Recent Nutrition Trends")
                                .font(.headline)
                                .foregroundColor(.blue)
                        )

                    // Recent Step Trends Card
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: UIScreen.main.bounds.height / 3.5)
                        .overlay(
                            Text("Recent Step Trends")
                                .font(.headline)
                                .foregroundColor(.blue)
                        )
                }
                .padding()
            }
        }
    }
}

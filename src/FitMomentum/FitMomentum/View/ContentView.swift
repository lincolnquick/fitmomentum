import SwiftUI

struct ContentView: View {
    @StateObject var userViewModel = UserViewModel() // Ensure `UserViewModel` is available

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

            // Progress Page
            NavigationView {
                ProgressPage()
            }
            .tabItem {
                Label("Progress", systemImage: "flag.fill")
            }
            .environmentObject(userViewModel) // Ensure the view model is passed down

            // More Menu
            NavigationView {
                MoreMenu()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
        }
        .environmentObject(userViewModel) // Ensures `userViewModel` is passed to all views
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
            .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) } // Ensure the header respects safe areas

            // Scrollable Content
            ScrollView {
                VStack(spacing: 20) {
                    // Recent Weight Trends Card
                    WeightTrendsCard()

                    // Weight Loss Progress Card
                    ProgressCard(title: "Weight Loss Progress")

                    // Daily Checklist Card
                    ProgressCard(title: "Daily Checklist")
                    
                    // Predictions Card
                    ProgressCard(title: "Predictions")
                    
                    // Recent Nutrition Trends Card
                    ProgressCard(title: "Recent Nutrition Trends")

                    // Recent Step Trends Card
                    ProgressCard(title: "Recent Step Trends")
                }
                .padding()
            }
        }
    }
}

// MARK: - Reusable Progress Card
struct ProgressCard: View {
    var title: String

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.gray.opacity(0.2))
            .frame(height: UIScreen.main.bounds.height / 3.5)
            .overlay(
                Text(title)
                    .font(.headline)
                    .foregroundColor(.blue)
            )
    }
}

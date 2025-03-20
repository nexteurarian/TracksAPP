import SwiftUI

struct Info: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("Hello 👋🏻 I'm Ian!")
                            .font(.system(size: horizontalSizeClass == .regular ? 40 : 32, weight: .bold))
                        
                        Text("Welcome to Tracks!")
                            .font(.system(size: horizontalSizeClass == .regular ? 34 : 28, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    Text("What should you expect from Tracks?")
                        .font(.system(size: horizontalSizeClass == .regular ? 28 : 24, weight: .medium))
                        .padding(.bottom, 8)
                    
                    let cardWidth = geometry.size.width - (horizontalSizeClass == .regular ? 80 : 40)
                    let iconWidth: CGFloat = horizontalSizeClass == .regular ? 44 : 36
                    
                    VStack(spacing: 27) {
                        FeatureRow(
                            icon: "rectangle.fill.on.rectangle.angled.fill",
                            title: "Track Your Courses!",
                            description: "Be on track with all of your courses for the semester. From the course codes to your schedule, Tracks has your back.",
                            iconColor: .green,
                            width: cardWidth,
                            iconWidth: iconWidth
                        )
                        
                        FeatureRow(
                            icon: "tray.2.fill",
                            title: "Assignments? Track it!",
                            description: "Never miss a deadline! With Tracks, every assignment is neatly organized so you can focus on what matters.",
                            iconColor: .red,
                            width: cardWidth,
                            iconWidth: iconWidth
                        )
                        
                        FeatureRow(
                            icon: "sparkles",
                            title: "Be Motivated to Track!",
                            description: "Tracks has a rewards system that converts every assignment completed to star points, which can be used to buy paintings (with suprises inside!)",
                            iconColor: .yellow,
                            width: cardWidth,
                            iconWidth: iconWidth
                        )
                    }
                }
                .frame(minHeight: geometry.size.height)
                .padding(.horizontal, horizontalSizeClass == .regular ? 40 : 20)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
    let width: CGFloat
    let iconWidth: CGFloat
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: horizontalSizeClass == .regular ? 32 : 24))
                    .foregroundColor(iconColor)
            }
            .frame(width: iconWidth)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: horizontalSizeClass == .regular ? 24 : 20, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .font(.system(size: horizontalSizeClass == .regular ? 18 : 16))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(width: width)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

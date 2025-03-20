import SwiftUI

struct Courses: View {
    @Binding var courses: [Course]
    @State private var showingAddCourse = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private func getGridColumns() -> [GridItem] {
        if horizontalSizeClass == .compact {
            return [GridItem(.flexible(), spacing: 20)]
        } else {
            return [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ]
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 20
            let columns = horizontalSizeClass == .compact ? 1 : 2
            let cardWidth = (geometry.size.width - (spacing * (CGFloat(columns) + 1))) / CGFloat(columns)
            
            ScrollView {
                LazyVGrid(columns: getGridColumns(), spacing: spacing) {
                    ForEach(courses) { course in
                        CourseCard(course: course, courses: $courses)
                            .frame(width: cardWidth, height: cardWidth)
                    }
                    
                    if courses.count < 7 {
                        Button(action: {
                            showingAddCourse = true
                        }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: cardWidth * 0.2))
                                Text("Add Course")
                                    .font(.system(size: cardWidth * 0.1))
                            }
                            .frame(width: cardWidth, height: cardWidth)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                }
                .padding(.horizontal, spacing)
                .padding(.vertical, spacing)
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingAddCourse) {
            AddCourseView(isPresented: $showingAddCourse, courses: $courses)
        }
    }
}

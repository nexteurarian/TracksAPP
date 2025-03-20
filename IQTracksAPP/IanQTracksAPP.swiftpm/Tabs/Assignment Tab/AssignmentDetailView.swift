import SwiftUI

struct AssignmentDetailView: View {
    @Binding var isPresented: Bool
    @Binding var assignments: [Assignment]
    let assignment: Assignment
    let courses: [Course]
    @EnvironmentObject var rewardsManager: RewardsManager
    
    @State private var isCompleted: Bool
    
    private var courseColor: Color {
        if let course = courses.first(where: { $0.id == assignment.courseId }),
           let colorOption = ColorOption.options.first(where: { $0.name == course.colorName }) {
            return colorOption.color
        }
        return .gray
    }
    
    init(isPresented: Binding<Bool>, assignments: Binding<[Assignment]>, assignment: Assignment, courses: [Course]) {
        self._isPresented = isPresented
        self._assignments = assignments
        self.assignment = assignment
        self.courses = courses
        self._isCompleted = State(initialValue: assignment.isCompleted)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    private func timeUntilDeadline() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: Date(), to: assignment.deadline)
        
        if let days = components.day, let hours = components.hour, let minutes = components.minute {
            if days < 0 || hours < 0 || minutes < 0 {
                return "Past due"
            }
            
            var countdown = ""
            if days > 0 { countdown += "\(days)d " }
            if hours > 0 { countdown += "\(hours)h " }
            if minutes > 0 { countdown += "\(minutes)m" }
            return countdown.isEmpty ? "Due now" : countdown.trimmingCharacters(in: .whitespaces)
        }
        return "Unknown"
    }
    
    private func deleteAssignment() {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments.remove(at: index)
        }
        isPresented = false
    }
    
    private func toggleCompletion() {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments[index].isCompleted.toggle()
            isCompleted = assignments[index].isCompleted
            
            if isCompleted {
                rewardsManager.addStarPoint()
            } else {
                rewardsManager.removeStarPoint()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(assignment.name)
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        
                        Button(action: toggleCompletion) {
                            Text("Mark as \(isCompleted ? "Incomplete" : "Done")")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isCompleted ? Color.gray : Color.green)
                                .cornerRadius(10)
                        }
                        
                        if !assignment.details.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Details")
                                    .font(.headline)
                                Text(assignment.details)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deadline")
                                .font(.headline)
                            HStack {
                                Text(formatDate(assignment.deadline))
                                Spacer()
                                Text(timeUntilDeadline())
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
                
                VStack {
                    Spacer()
                    courseColor
                        .frame(height: 50)
                }
            }
            .navigationBarItems(
                leading: Button(action: deleteAssignment) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                },
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

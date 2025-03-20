import SwiftUI

struct AddAssignmentView: View {
    @Binding var isPresented: Bool
    @Binding var assignments: [Assignment]
    let courses: [Course]
    
    @State private var assignmentName = ""
    @State private var assignmentDetails = ""
    @State private var selectedCourse: Course?
    @State private var deadline: Date = {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) {
            components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        }
        components.hour = 23
        components.minute = 59
        components.second = 0
        
        return calendar.date(from: components) ?? Date()
    }()
    
    private func assignmentCountForCourse(_ courseId: UUID) -> Int {
        return assignments.filter { $0.courseId == courseId }.count
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Assignment Details")) {
                    TextField("Assignment Name", text: $assignmentName)
                        .onChange(of: assignmentName) { _, newValue in
                            if newValue.count > 32 {
                                assignmentName = String(newValue.prefix(32))
                            }
                        }
                    
                    TextEditor(text: $assignmentDetails)
                        .frame(height: 100)
                        .padding(.horizontal, -5)
                        .onChange(of: assignmentDetails) { _, newValue in
                            if newValue.count > 250 {
                                assignmentDetails = String(newValue.prefix(250))
                            }
                        }
                    Text("\(250 - assignmentDetails.count) characters remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Deadline")) {
                    VStack(spacing: 8) {
                        DatePicker("", selection: $deadline, in: Date()...)
                            .labelsHidden()
                    }
                }
                
                Section(header: Text("Assigned Course")) {
                    ForEach(courses) { course in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(course.name)
                                Text("\(5 - assignmentCountForCourse(course.id)) slots remaining")
                                    .font(.caption)
                                    .foregroundColor(assignmentCountForCourse(course.id) >= 5 ? .red : .secondary)
                            }
                            Spacer()
                            if selectedCourse?.id == course.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if assignmentCountForCourse(course.id) < 5 {
                                selectedCourse = course
                            }
                        }
                        .opacity(assignmentCountForCourse(course.id) >= 5 ? 0.5 : 1)
                    }
                }
            }
            .navigationTitle("Add Assignment")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    if let course = selectedCourse {
                        let newAssignment = Assignment(
                            name: assignmentName,
                            details: assignmentDetails,
                            deadline: deadline,
                            courseId: course.id
                        )
                        assignments.append(newAssignment)
                    }
                    isPresented = false
                }
                    .disabled(assignmentName.isEmpty || selectedCourse == nil)
            )
        }
    }
}

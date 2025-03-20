import SwiftUI

struct Assignments: View {
    let courses: [Course]
    @State private var expandedCourses: Set<UUID> = []
    @State private var showingAddAssignment = false
    @State private var assignments: [Assignment] = []
    @State private var showingNoCourseAlert = false
    @State private var selectedAssignment: Assignment?
    @State private var showingAssignmentDetail = false
    @State private var showingBugAlert = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var splitCourses: ([Course], [Course]) {
        let midIndex = (courses.count + 1) / 2
        return (Array(courses.prefix(midIndex)), Array(courses.suffix(from: midIndex)))
    }
    
    private func assignmentsForCourse(_ course: Course) -> [Assignment] {
        assignments.filter { $0.courseId == course.id }
    }
    
    private func isPassedDeadline(_ assignment: Assignment) -> Bool {
        return Date() > assignment.deadline
    }
    
    private func AssignmentRow(_ assignment: Assignment) -> some View {
        Text(assignment.name)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        assignment.isCompleted ? Color.green.opacity(0.2) :
                            (isPassedDeadline(assignment) ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    )
            )
            .foregroundColor(
                assignment.isCompleted ? .green :
                    (isPassedDeadline(assignment) ? .red : .blue)
            )
            .onTapGesture {
                selectedAssignment = assignment
                showingAssignmentDetail = true
            }
    }
    
    private func CourseColumn(courses: [Course]) -> some View {
        LazyVStack(spacing: 16) {
            ForEach(courses) { course in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedCourses.contains(course.id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedCourses.insert(course.id)
                            } else {
                                expandedCourses.remove(course.id)
                            }
                        }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        let courseAssignments = assignmentsForCourse(course)
                        if courseAssignments.isEmpty {
                            Text("No assignments yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(courseAssignments) { assignment in
                                AssignmentRow(assignment)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } label: {
                    Text(course.name)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: {
                        if courses.isEmpty {
                            showingNoCourseAlert = true
                        } else {
                            showingAddAssignment = true
                        }
                    }) {
                        Text("Add Assignment")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: horizontalSizeClass == .regular ? 360 : 230)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {
                        showingBugAlert = true
                    }) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(height: 45)
                            .padding(.horizontal, 12)
                            .background(
                                Circle()
                                    .fill(Color.orange)
                            )
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .alert("Can't Create Assignment", isPresented: $showingNoCourseAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("To add assignments, create a course first.")
                }
                .alert("Issue", isPresented: $showingBugAlert) {
                    Button("I understand", role: .cancel) { }
                } message: {
                    Text("Hello! There is a bug that I haven't been able to fix yet. When a user creates their first assignment, clicking on it doesn't display anything. As a temporary workaround, the user can create another assignment. When this new assignment is clicked, the properties of both the first assignment and the new one appear. Alternatively, rescaling the app to a smaller size and then back to its original size with the window opened also resolves the issue. I apologize for the inconvenience.")
                }
                
                if horizontalSizeClass == .regular {
                    HStack(alignment: .top, spacing: 16) {
                        let (leftColumn, rightColumn) = splitCourses
                        
                        CourseColumn(courses: leftColumn)
                            .frame(maxWidth: .infinity)
                        
                        CourseColumn(courses: rightColumn)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: 1200)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(courses) { course in
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedCourses.contains(course.id) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedCourses.insert(course.id)
                                        } else {
                                            expandedCourses.remove(course.id)
                                        }
                                    }
                                )
                            ) {
                                VStack(alignment: .leading, spacing: 8) {
                                    let courseAssignments = assignmentsForCourse(course)
                                    if courseAssignments.isEmpty {
                                        Text("No assignments yet")
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical, 8)
                                    } else {
                                        ForEach(courseAssignments) { assignment in
                                            AssignmentRow(assignment)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            } label: {
                                Text(course.name)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingAddAssignment) {
            AddAssignmentView(isPresented: $showingAddAssignment, assignments: $assignments, courses: courses)
        }
        .sheet(isPresented: $showingAssignmentDetail) {
            if let assignment = selectedAssignment {
                AssignmentDetailView(
                    isPresented: $showingAssignmentDetail,
                    assignments: $assignments,
                    assignment: assignment,
                    courses: courses
                )
            }
        }
    }
}

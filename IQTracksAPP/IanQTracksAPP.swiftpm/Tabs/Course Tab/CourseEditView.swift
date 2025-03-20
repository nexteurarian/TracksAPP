import SwiftUI

struct CourseEditView: View {
    let course: Course
    @Binding var isPresented: Bool
    @Binding var courses: [Course]
    @State private var showingDeleteAlert = false
    
    @State private var courseName: String
    @State private var courseCode: String
    @State private var selectedColorName: String
    @State private var courseStartTime: Date
    @State private var courseEndTime: Date
    @State private var selectedDays: Set<WeekDay>
    
    let timeRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(bySettingHour: 1, minute: 0, second: 0, of: now)!
        let endTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: now)!
        return startTime...endTime
    }()
    
    private var availableColors: [ColorOption] {
        let otherCoursesColors = Set(courses.filter { $0.id != course.id }.map { $0.colorName })
        return ColorOption.options.filter { !otherCoursesColors.contains($0.name) || $0.name == selectedColorName }
    }
    
    init(course: Course, isPresented: Binding<Bool>, courses: Binding<[Course]>) {
        self.course = course
        self._isPresented = isPresented
        self._courses = courses
        
        _courseName = State(initialValue: course.name)
        _courseCode = State(initialValue: course.code)
        _selectedColorName = State(initialValue: course.colorName)
        _courseStartTime = State(initialValue: course.startTime)
        _courseEndTime = State(initialValue: course.endTime)
        _selectedDays = State(initialValue: course.days)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Details")) {
                    TextField("Course Name", text: $courseName)
                        .onChange(of: courseName) { _, newValue in
                            if newValue.count > 40 {
                                courseName = String(newValue.prefix(40))
                            }
                        }
                    
                    TextField("Course Code", text: $courseCode)
                        .textInputAutocapitalization(.characters)
                        .onChange(of: courseCode) { _, newValue in
                            let uppercase = newValue.uppercased()
                            if uppercase.count > 8 {
                                courseCode = String(uppercase.prefix(8))
                            } else {
                                courseCode = uppercase
                            }
                        }
                    
                    DatePicker("Starts:", selection: $courseStartTime, in: timeRange, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                    
                    DatePicker("Ends:", selection: $courseEndTime, in: timeRange, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                }
                
                Section(header: Text("Course Color")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(availableColors) { colorOption in
                                Circle()
                                    .fill(colorOption.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(white: 0.8), lineWidth: selectedColorName == colorOption.name ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColorName = colorOption.name
                                    }
                            }
                            .padding(.horizontal, 10.2)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Course Days")) {
                    ForEach(WeekDay.allCases) { day in
                        Toggle(day.rawValue, isOn: Binding(
                            get: { selectedDays.contains(day) },
                            set: { isSelected in
                                if isSelected {
                                    selectedDays.insert(day)
                                } else {
                                    selectedDays.remove(day)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Edit Current Course")
            .navigationBarItems(
                leading: Button(action: {
                    showingDeleteAlert = true
                }) {
                    Text("Delete")
                        .foregroundColor(.red)
                },
                trailing: Button("Update") {
                    if let index = courses.firstIndex(where: { $0.id == course.id }) {
                        courses[index] = Course(
                            name: courseName,
                            code: courseCode,
                            startTime: courseStartTime,
                            endTime: courseEndTime,
                            days: selectedDays,
                            colorName: selectedColorName
                        )
                    }
                    isPresented = false
                }
                    .disabled(courseName.isEmpty ||
                              courseCode.isEmpty ||
                              selectedDays.isEmpty ||
                              selectedColorName.isEmpty ||
                              courseEndTime <= courseStartTime)
            )
            .alert("Delete Course", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    courses.removeAll { $0.id == course.id }
                    isPresented = false
                }
            } message: {
                Text("Are you sure you want to delete this course? This action cannot be undone.")
            }
        }
    }
}

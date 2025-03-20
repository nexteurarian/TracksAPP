import SwiftUI

public struct AddCourseView: View {
    @Binding var isPresented: Bool
    @Binding var courses: [Course]
    
    @State private var courseName = ""
    @State private var courseCode = ""
    @State private var selectedColorName = ""
    
    @State private var courseStartTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now
    }()
    
    @State private var courseEndTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        let defaultStart = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now
        return calendar.date(byAdding: .hour, value: 1, to: defaultStart) ?? now
    }()
    
    @State private var selectedDays: Set<WeekDay> = []
    
    private var availableColors: [ColorOption] {
        let usedColors = Set(courses.map { $0.colorName })
        return ColorOption.options.filter { !usedColors.contains($0.name) }
    }
    
    let timeRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(bySettingHour: 1, minute: 0, second: 0, of: now)!
        let endTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: now)!
        return startTime...endTime
    }()
    
    public init(isPresented: Binding<Bool>, courses: Binding<[Course]>) {
        self._isPresented = isPresented
        self._courses = courses
    }
    
    public var body: some View {
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
            .navigationTitle("Add New Course")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    let newCourse = Course(
                        name: courseName,
                        code: courseCode,
                        startTime: courseStartTime,
                        endTime: courseEndTime,
                        days: selectedDays,
                        colorName: selectedColorName
                    )
                    courses.append(newCourse)
                    isPresented = false
                }
                    .disabled(courseName.isEmpty ||
                              courseCode.isEmpty ||
                              selectedDays.isEmpty ||
                              selectedColorName.isEmpty ||
                              courseEndTime <= courseStartTime)
            )
        }
    }
}

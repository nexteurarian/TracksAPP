import SwiftUI

public struct CourseCard: View {
    let course: Course
    @Binding var courses: [Course]
    
    @State private var currentDate = Date()
    @State private var showingCourseDetail = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private var assignedColor: Color {
        if let option = ColorOption.options.first(where: { $0.name == course.colorName }) {
            return option.color
        } else {
            return .gray
        }
    }
    
    private func sortedDays() -> [WeekDay] {
        let orderMap: [WeekDay: Int] = [
            .monday: 0,
            .tuesday: 1,
            .wednesday: 2,
            .thursday: 3,
            .friday: 4,
            .saturday: 5,
            .sunday: 6
        ]
        return Array(course.days).sorted { orderMap[$0] ?? 0 < orderMap[$1] ?? 0 }
    }
    
    private func nextOccurrence(from date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: course.startTime)
        let endTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: course.endTime)
        
        var nearestStart: Date?
        var correspondingEnd: Date?
        
        for dayOffset in 0...7 {
            let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: date) ?? date
            let futureDateWeekday = calendar.component(.weekday, from: futureDate)
            
            for day in course.days {
                let targetWeekday: Int = {
                    switch day {
                    case .sunday: return 1
                    case .monday: return 2
                    case .tuesday: return 3
                    case .wednesday: return 4
                    case .thursday: return 5
                    case .friday: return 6
                    case .saturday: return 7
                    }
                }()
                
                if futureDateWeekday == targetWeekday {
                    var startComponents = calendar.dateComponents([.year, .month, .day], from: futureDate)
                    startComponents.hour = startTimeComponents.hour
                    startComponents.minute = startTimeComponents.minute
                    startComponents.second = startTimeComponents.second
                    
                    if let potentialStart = calendar.date(from: startComponents) {
                        var endComponents = calendar.dateComponents([.year, .month, .day], from: futureDate)
                        endComponents.hour = endTimeComponents.hour
                        endComponents.minute = endTimeComponents.minute
                        endComponents.second = endTimeComponents.second
                        
                        if let potentialEnd = calendar.date(from: endComponents) {
                            let adjustedEnd = potentialEnd >= potentialStart ? potentialEnd : calendar.date(byAdding: .day, value: 1, to: potentialEnd) ?? potentialEnd
                            
                            if potentialStart >= date || (potentialStart...adjustedEnd).contains(date) {
                                if nearestStart == nil || potentialStart < nearestStart! {
                                    nearestStart = potentialStart
                                    correspondingEnd = adjustedEnd
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return (start: nearestStart ?? course.startTime,
                end: correspondingEnd ?? course.endTime)
    }
    
    private func formatTimeInterval(_ interval: TimeInterval, includeDays: Bool) -> String {
        let totalSeconds = Int(interval)
        if totalSeconds <= 0 {
            return includeDays ? "0d: 0h: 0m: 0s" : "0h: 0m: 0s"
        }
        if includeDays {
            let days = totalSeconds / (24 * 3600)
            let hours = (totalSeconds % (24 * 3600)) / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            return "\(days)d: \(hours)h: \(minutes)m: \(seconds)s"
        } else {
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            return "\(hours)h: \(minutes)m: \(seconds)s"
        }
    }
    
    private enum CountdownState {
        case beforeStart(timeLeft: TimeInterval)
        case duringClass(timeLeft: TimeInterval)
        case waiting
    }
    
    private func getCountdownState() -> CountdownState {
        let calendar = Calendar.current
        let occurrence = nextOccurrence(from: currentDate)
        
        if currentDate >= occurrence.start && currentDate < occurrence.end {
            return .duringClass(timeLeft: occurrence.end.timeIntervalSince(currentDate))
        }
        
        let nextStart = occurrence.start
        if currentDate < nextStart {
            return .beforeStart(timeLeft: nextStart.timeIntervalSince(currentDate))
        }
        
        let futureOccurrence = nextOccurrence(from: calendar.date(byAdding: .minute, value: 1, to: occurrence.end) ?? occurrence.end)
        return .beforeStart(timeLeft: futureOccurrence.start.timeIntervalSince(currentDate))
    }
    
    @ViewBuilder
    private func countdownView() -> some View {
        let state = getCountdownState()
        
        switch state {
        case .beforeStart(let timeLeft):
            HStack(spacing: 4) {
                Text("Starts in")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                Text(" ≈ ")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                Text(formatTimeInterval(timeLeft, includeDays: true))
                    .font(.system(size: 20))
            }
            .padding(8)
            .background(Color.green.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
        case .duringClass(let timeLeft):
            HStack(spacing: 4) {
                Text("Ends in")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                Text(" ≈ ")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                Text(formatTimeInterval(timeLeft, includeDays: false))
                    .font(.system(size: 20))
            }
            .padding(8)
            .background(Color.red.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
        case .waiting:
            EmptyView()
        }
    }
    
    public init(course: Course, courses: Binding<[Course]>) {
        self.course = course
        self._courses = courses
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Button(action: {
                showingCourseDetail = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 2)
                    
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.03) {
                        GeometryReader { nameGeometry in
                            Text(course.name)
                                .font(.system(size: 500))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.01)
                                .frame(
                                    width: nameGeometry.size.width,
                                    height: nameGeometry.size.height,
                                    alignment: .leading
                                )
                        }
                        .frame(height: geometry.size.height * 0.15)
                        
                        GeometryReader { textGeometry in
                            Text(course.code)
                                .font(.system(size: 500, weight: .light))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .frame(width: textGeometry.size.width, height: textGeometry.size.height, alignment: .leading)
                                .scaledToFit()
                        }
                        .frame(height: geometry.size.height * 0.2)
                        
                        Text("\(timeFormatter.string(from: course.startTime)) - \(timeFormatter.string(from: course.endTime))")
                            .font(.system(size: geometry.size.width * 0.08))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: geometry.size.width * 0.02) {
                                ForEach(sortedDays(), id: \.self) { day in
                                    Text(day.shortName)
                                        .font(.system(size: geometry.size.width * 0.06))
                                        .padding(.horizontal, geometry.size.width * 0.03)
                                        .padding(.vertical, geometry.size.width * 0.01)
                                        .background(Color.blue.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.03))
                                }
                            }
                        }
                        
                        countdownView()
                        
                        Spacer(minLength: 0)
                    }
                    .padding(geometry.size.width * 0.06)
                    
                    VStack {
                        Spacer()
                        Color.clear.frame(height: 10)
                        assignedColor
                            .frame(height: geometry.size.height * 0.09)
                            .frame(maxWidth: .infinity)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingCourseDetail) {
                CourseEditView(course: course, isPresented: $showingCourseDetail, courses: $courses)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onReceive(timer) { input in
                currentDate = input
            }
        }
    }
}

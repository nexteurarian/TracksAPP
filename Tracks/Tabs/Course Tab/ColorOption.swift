import SwiftUI

struct ColorOption: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: Color
    
    static let options: [ColorOption] = [
        ColorOption(name: "Crimson", color: Color(red: 220/255, green: 20/255, blue: 60/255)),
        ColorOption(name: "Azure", color: Color(red: 0/255, green: 127/255, blue: 255/255)),
        ColorOption(name: "Emerald", color: Color(red: 46/255, green: 204/255, blue: 113/255)),
        ColorOption(name: "Goldenrod", color: Color(red: 218/255, green: 165/255, blue: 32/255)),
        ColorOption(name: "Amethyst", color: Color(red: 153/255, green: 102/255, blue: 204/255)),
        ColorOption(name: "Coral", color: Color(red: 255/255, green: 127/255, blue: 80/255)),
        ColorOption(name: "Slate Gray", color: Color(red: 112/255, green: 128/255, blue: 144/255))
    ]
}


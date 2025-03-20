import SwiftUI

class RewardsManager: ObservableObject {
    @Published private(set) var starPoints: Int = 0
    @Published var unlockedCards: Set<Int> = []
    
    static let cardCosts: [Int] = [5, 10, 10, 5]
    
    func addStarPoint() {
        starPoints += 1
    }
    
    func removeStarPoint() {
        starPoints = max(0, starPoints - 1)
    }
    
    func tryUnlockCard(index: Int) -> Bool {
        let cost = RewardsManager.cardCosts[index]
        if starPoints >= cost && !unlockedCards.contains(index) {
            starPoints -= cost
            unlockedCards.insert(index)
            return true
        }
        return false
    }
    
    func isCardUnlocked(index: Int) -> Bool {
        return unlockedCards.contains(index)
    }
}

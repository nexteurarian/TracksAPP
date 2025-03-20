import SwiftUI

struct Rewards: View {
    @ObservedObject var rewardsManager: RewardsManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showingUnlockAlert = false
    @State private var selectedCardIndex: Int?
    @State private var showingCardDetail = false
    
    private let numberOfRewardCards = 4
    
    private let cardImages = ["auroraborealis", "festivalharbor", "salvagestate", "rockymountain"]
    
    private let cardContents = [
        ("Aurora Borealis - Frederic Edwin Church (1865)", "Did you know that many deep-sea organisms produce their own light through bioluminescence? These creatures use this capability for hunting, mating, and camouflage.\n\nSome of the well-known bioluminescent deep-sea creatures include anglerfish (the one that Dory and Marlin met in the dark depths in Finding Nemo), hatchet fish (with light-producing organs on their bellies), and vampire squid (which emits a bioluminescent cloud when threatened)."),
        ("Festival in the Harbor of Honfleur - Eugène Boudin (1858)", "While Earth's wind patterns are impressive, other planets take wind speeds to another level. For instance, Neptune is known to have some of the fastest winds in the solar system, with speeds reaching up to 1,200 mph, despite its great distance from the Sun. I wonder how fast sail ships could sail there."),
        ("The Rocky Mountains, Lander's Peak - Albert Bierstadt (1863)", "Have you ever thought that mountains could be the water towers of the world? This is because mountains store water in the form of snow and glaciers. As they melt, this water feeds rivers and lakes, supporting ecosystems and human populations far downstream."),
        ("The Course of Empire: The Savage State - Thomas Cole (1834)", "Did you know that over 2 billion years ago, tiny cyanobacteria transformed Earth's atmosphere? These simple, photosynthetic microorganisms sparked the Great Oxygenation Event by producing oxygen as a byproduct of photosynthesis. This dramatic shift not only reshaped our planet's environment but also paved the way for the evolution of complex life. Much like the untamed, raw wilderness depicted in the painiting, early Earth was a wild, ever-changing realm where even the smallest organisms could have monumental impacts.")
    ]
    
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
                VStack(spacing: 24) {
                    if horizontalSizeClass == .regular {
                        VStack(spacing: 16) {
                            VStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 32))
                                    
                                    Text("\(rewardsManager.starPoints)")
                                        .font(.system(size: 32, weight: .bold))
                                }
                                
                                Text("Star Points")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 3, y: 2)
                            )
                            
                            Text("For every assignment completed,\nyou earn one star point")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, spacing)
                    } else {
                        HStack(spacing: 16) {
                            VStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 32))
                                    
                                    Text("\(rewardsManager.starPoints)")
                                        .font(.system(size: 32, weight: .bold))
                                }
                                
                                Text("Star Points")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 3, y: 2)
                            )
                            
                            Text("For every assignment completed, you earn one star point")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, spacing)
                    }
                    
                    LazyVGrid(columns: getGridColumns(), spacing: spacing) {
                        ForEach(0..<numberOfRewardCards, id: \.self) { index in
                            ZStack {
                                Image(cardImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: cardWidth, height: cardWidth)
                                    .opacity(rewardsManager.isCardUnlocked(index: index) ? 1.0 : 0.5)
                                
                                if !rewardsManager.isCardUnlocked(index: index) {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            HStack(spacing: 4) {
                                                Text("\(RewardsManager.cardCosts[index])")
                                                    .font(.system(size: 20, weight: .bold))
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 16))
                                            }
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.white)
                                            )
                                            .foregroundColor(.yellow)
                                            .padding(8)
                                        }
                                        Spacer()
                                    }
                                }
                                
                                if !rewardsManager.isCardUnlocked(index: index) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 4)
                                }
                            }
                            .frame(width: cardWidth, height: cardWidth)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 2)
                            .onTapGesture {
                                selectedCardIndex = index
                                if rewardsManager.isCardUnlocked(index: index) {
                                    showingCardDetail = true
                                } else if rewardsManager.starPoints >= RewardsManager.cardCosts[index] {
                                    showingUnlockAlert = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, spacing)
                }
                .padding(.vertical, spacing)
            }
            .background(Color(.systemGroupedBackground))
            .alert("Unlock this card?", isPresented: $showingUnlockAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Unlock") {
                    if let index = selectedCardIndex {
                        if rewardsManager.tryUnlockCard(index: index) {
                            showingCardDetail = true
                        }
                    }
                }
            } message: {
                if let index = selectedCardIndex {
                    Text("This will cost \(RewardsManager.cardCosts[index]) star points")
                }
            }
            .sheet(isPresented: $showingCardDetail) {
                if let index = selectedCardIndex {
                    CardDetailView(imageName: cardImages[index], title: cardContents[index].0, content: cardContents[index].1)
                }
            }
        }
    }
}

struct CardDetailView: View {
    let imageName: String
    let title: String
    let content: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 200)
                .clipped()
                .edgesIgnoringSafeArea(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .italic()
                
                Text(content)
                    .font(.title3)
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

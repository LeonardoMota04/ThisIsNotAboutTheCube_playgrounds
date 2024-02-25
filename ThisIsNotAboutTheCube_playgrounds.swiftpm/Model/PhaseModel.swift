import SwiftUI
import SceneKit

// PHASES MODEL
struct PhaseModel {
    var phaseNumber: Int
    var title: String
    var actionLabel: String
    var backgroundColor: Color
    var movementsRequired: Int
    
    init(phaseNumber: Int, title: String = "", actionLabel: String = "", backgroundColor: Color, movementsRequired: Int) {
        self.phaseNumber = phaseNumber
        self.title = title
        self.actionLabel = actionLabel
        self.backgroundColor = backgroundColor
        self.movementsRequired = movementsRequired
    }
    
    /// phases
    static var phases: [PhaseModel] = [
            /// Onboarding
        PhaseModel(phaseNumber: 0, 
                   backgroundColor: AppColor.bg_white.color,
                   movementsRequired: 3),
            /// 1
            PhaseModel(phaseNumber: 1,
                       title: "Denial",
                       actionLabel: "This can't be happening, it must be a nightmare",
                       backgroundColor: .black,
                       movementsRequired: 5),
            /// 2
            PhaseModel(phaseNumber: 2, 
                       title: "Anger",
                       actionLabel: "It is not fair! Why Me? Why now? Why?",
                       backgroundColor: .black,
                       movementsRequired: 10),
            
            /// 3
            PhaseModel(phaseNumber: 3, 
                       title: "Bargaining",
                       actionLabel: "Please, give me one more chance!",
                       backgroundColor: .black,
                       movementsRequired: 6),
            /// 4
            PhaseModel(phaseNumber: 4, 
                       title: "Depression",
                       actionLabel: "Nothing will be like before...",
                       backgroundColor: .black,
                       movementsRequired: 10),
            /// 5
            PhaseModel(phaseNumber: 5, 
                       title: "Acceptance",
                       actionLabel: "It is going to be hard but I have to keep moving...",
                       backgroundColor: AppColor.bg_white.color,
                       movementsRequired: 15),
    ]
}

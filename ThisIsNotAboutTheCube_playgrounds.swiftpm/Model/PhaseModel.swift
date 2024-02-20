//
//  PhaseModel.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 18/01/24.
//

import Foundation
import SwiftUI
import SceneKit

struct PhaseModel {
    var phaseNumber: Int
    var title: String
    var subtitle: String
    var actionLabel: String
    var backgroundColor: Color
    var movementsRequired: Int
    
    init(phaseNumber: Int, title: String, subtitle: String, actionLabel: String, backgroundColor: Color, movementsRequired: Int) {
        self.phaseNumber = phaseNumber
        self.title = title
        self.subtitle = subtitle
        self.actionLabel = actionLabel
        self.backgroundColor = backgroundColor
        self.movementsRequired = movementsRequired
    }
    
    /// phases
    static var phases: [PhaseModel] = [
            /// Onboarding
        PhaseModel(phaseNumber: 0, 
                   title: "",
                   subtitle: "",
                   actionLabel: "",
                   backgroundColor: AppColor.bg_white.color,
                   movementsRequired: 3),
            /// 1
            PhaseModel(phaseNumber: 1,
                       title: "Denial",
                       subtitle: "",
                       actionLabel: "This can't be happening, it must be a nightmare",
                       backgroundColor: .black,
                       movementsRequired: 5),
            /// 2
            PhaseModel(phaseNumber: 2, 
                       title: "Anger",
                       subtitle: "",
                       actionLabel: "It is not fair! Why Me? Why now? Why?",
                       backgroundColor: .black,
                       movementsRequired: 10),
            
            /// 3
            PhaseModel(phaseNumber: 3, 
                       title: "Bargaining",
                       subtitle: "",
                       actionLabel: "Please, give me one more chance!",
                       backgroundColor: .black,
                       movementsRequired: 6),
            /// 4
            PhaseModel(phaseNumber: 4, 
                       title: "Depression",
                       subtitle: "",
                       actionLabel: "Nothing will be like before...",
                       backgroundColor: .black,
                       movementsRequired: 2),
            /// 5
            PhaseModel(phaseNumber: 5, 
                       title: "Acceptance",
                       subtitle: "",
                       actionLabel: "It is going to be hard but I have to keep moving...",
                       backgroundColor: AppColor.bg_white.color,
                       movementsRequired: 2),
            
    ]

    
}

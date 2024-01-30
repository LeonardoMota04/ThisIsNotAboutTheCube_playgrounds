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
    //var lightning: SCNLight
    // texture
}

//let cubePhases = [
//    PhaseModel(phaseNumber: 1, title: "Clareca amoreca", backgroundColor: .blue),
//    PhaseModel(phaseNumber: 2, title: "sr panday sdds", backgroundColor: .purple)
//]

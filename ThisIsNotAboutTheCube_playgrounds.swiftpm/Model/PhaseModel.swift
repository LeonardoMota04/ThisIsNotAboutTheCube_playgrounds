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
                       title: "O PRIMEIRO PASSO",
                       subtitle: "O ínicio. \nÉ normal sentir medo quando desafios aparecem em nossas vidas, muitas vezes não sabemos nem por onde começar. Mas é importante não pular etapas.",
                       actionLabel: "Respeite o seu tempo - comece por baixo...",
                       backgroundColor: .black,
                       movementsRequired: 1),
            /// 2
            PhaseModel(phaseNumber: 2, 
                       title: "NADA PARECE CERTO",
                       subtitle: "“A man of genius makes no mistakes; his errors are volitional and are the portals of discovery” \n- James Joyce",
                       actionLabel: "Erre, erre, se perca. Uma hora vai dar certo...",
                       backgroundColor: .red,
                       movementsRequired: 8),
            
            /// 3
            PhaseModel(phaseNumber: 3, 
                       title: "RECOMPOR",
                       subtitle: "",
                       actionLabel: "ACAO3",
                       backgroundColor: .green,
                       movementsRequired: 5),
            /// 4
            PhaseModel(phaseNumber: 4, 
                       title: "LOST",
                       subtitle: "É hora de desistir, tudo parece em vão.",
                       actionLabel: "Pode tentar mover, você não sabe o que faz...",
                       backgroundColor: .purple,
                       movementsRequired: 10),
            /// 5
            PhaseModel(phaseNumber: 5, 
                       title: "FOUND",
                       subtitle: "Mesmo nos momentos difíceis, agarre-se às pequenas oportunidades, tudo fará sentido.",
                       actionLabel: "Continue tentando...",
                       backgroundColor: .red,
                       movementsRequired: 15),
            /// 6
            PhaseModel(phaseNumber: 6, 
                       title: "STABILITY",
                       subtitle: "Depois que engajamos na solução, tudo fica mais leve, a busca pela estabilidade é importante em momentos de angústia!",
                       actionLabel: "Aproveite, mas mantenha o foco...",
                       backgroundColor: .white,
                       movementsRequired: 10),
            /// 7
            PhaseModel(phaseNumber: 7, 
                       title: "STUCK",
                       subtitle: "Esse é o problema de relaxar demais: a procrastinação tende a nos deixar estagnados. É hora de correr atrás do que perdemos...",
                       actionLabel: "",
                       backgroundColor: .red,
                       movementsRequired: 20),
            /// 8
            PhaseModel(phaseNumber: 8, 
                       title: "FASE 8 TÍTULO AQUI",
                       subtitle: "",
                       actionLabel: "ACAO8",
                       backgroundColor: .blue,
                       movementsRequired: 5),
            /// 9
            PhaseModel(phaseNumber: 9, 
                       title: "FASE 9 TÍTULO AQUI",
                       subtitle: "", 
                       actionLabel: "ACAO9",
                       backgroundColor: .purple, 
                       movementsRequired: 5),
    ]

    
}

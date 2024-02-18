//
//  ThisIsNotAboutTheCubeApp.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 05/12/23.
//

import SwiftUI

@main
struct ThisIsNotAboutTheCubeApp: App {
    var viewController = ViewController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewController)
        }
    }
}

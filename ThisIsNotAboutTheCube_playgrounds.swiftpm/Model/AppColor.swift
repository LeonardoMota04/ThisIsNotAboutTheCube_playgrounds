import SwiftUI

enum AppColor: String, CaseIterable {
    case bg_white
    case color_darkerGray
    case color_middleGray
    case color_thirdGray
    case color_lighterGray
    
    var color: Color {
        return Color(UIColor(named: rawValue) ?? .clear)
    }
}


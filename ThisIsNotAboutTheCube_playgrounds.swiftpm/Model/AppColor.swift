import SwiftUI

enum AppColor: String, CaseIterable {
    case bg_white
    case darkerGray
    case middleGray
    case thirdGray
    case lighterGray
    
    var color: Color {
        return Color(UIColor(named: rawValue) ?? .clear)
    }
}


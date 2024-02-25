import Foundation
import SwiftUI

// PROGRAMATIC SQUARES THAT GOES AS BACKGROUND
struct SquaresView: View {
    @EnvironmentObject var vc: ViewController
    
    // Background black hole
    @State private var bgHoleOpacity: Double = 1.0
    @State private var bgHoleScale: Double = 0.0
    @State private var bgLinesScale: Double = 1
    
    var body: some View {
        if !vc.readOnBoardingText1 {
            // LINES
            SquaresViewStroke(scale: bgLinesScale, numOfSquares: 6)
                .onChange(of: vc.firstEverTouch) { newValue in
                    if newValue == true {
                        if !vc.finishedOnboarding {
                            //lines get bigger
                            withAnimation(.easeInOut(duration: 12)){
                                self.bgLinesScale = 8.0
                            }
                        }
                    }
                }
        } else {
            // HOLE
            SquaresViewFilled(scale: bgHoleScale, numOfSquares: 5).opacity(bgHoleOpacity)
                .onChange(of: vc.firstEverTouch) { newValue in
                    if newValue == true {
                        if vc.finishedOnboarding {
                            bgHoleScale = 0
                            bgHoleOpacity = 1
                            withAnimation(.easeInOut(duration: 4.0)) {
                                bgHoleScale = 10
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                bgHoleOpacity = 0
                            }
                        }
                    }
                }
                .onChange(of: vc.finishedOnboarding) { _ in
                    withAnimation(.easeIn(duration: 4.0).delay(2)) {
                        bgHoleScale = 10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        bgHoleOpacity = 0
                    }
                }
        }
    }
}

// MARK: - SQUARES VIEW - STROKE
struct SquaresViewStroke: View {
    var scale: CGFloat = 1
    let numOfSquares: Int
    
    init(scale: CGFloat, numOfSquares: Int) {
        self.scale = scale
        self.numOfSquares = numOfSquares
    }
    
    var body: some View {
        ZStack {
            ForEach(1...numOfSquares, id: \.self) { i in
                Rectangle()
                .stroke(lineWidth: 5)
                .frame(width: CGFloat(i * 200), height: CGFloat(i * 200))
                .rotationEffect(Angle(degrees: i != 1 ? -Double((i) * 4) : .zero  ))
                .foregroundStyle(AppColor.color_lighterGray.color)
                .scaleEffect(scale)
            }
        }
    }
}

// MARK: - SQUARES VIEW - FILLED
struct SquaresViewFilled: View {
    var scale: CGFloat = 1
    let numOfSquares: Int
    
    let colors: [Color] = [
        .black,
        Color(UIColor(named: "color_darkerGray")!),
        Color(UIColor(named: "color_middleGray")!),
        Color(UIColor(named: "color_thirdGray")!),
        Color(UIColor(named: "color_lighterGray")!),
    ]
    
    init(scale: CGFloat, numOfSquares: Int) {
        self.scale = scale
        self.numOfSquares = numOfSquares
    }
    
    var body: some View {
        ZStack {
            ForEach((0..<numOfSquares).reversed(), id: \.self) { i in
                Rectangle()
                    .frame(width: CGFloat((i + 1) * 200), height: CGFloat((i+1) * 200))
                    .rotationEffect(Angle(degrees: -Double(i * 4)))
                    .foregroundStyle(colors[i])
                    .scaleEffect(scale)
            }
        }
    }
}

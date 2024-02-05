import Foundation
import SwiftUI

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
                .foregroundStyle(Color(UIColor(named: "color_lighterGray")!))
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

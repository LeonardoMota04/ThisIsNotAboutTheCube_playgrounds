//
//  SwiftUIView.swift
//  UIKITCOPIA
//
//  Created by Leonardo Mota on 05/12/23.
//

import SwiftUI
import SceneKit
import CoreImage

struct LampView: View {
    @State private var isLightFlashing = false
    @State private var randomOpacity: Double = 0.5
    @ObservedObject private var vc = ViewController()
    
    var body: some View {
        ZStack {
            // Luz em forma de triângulo
                LinearGradient(
                    gradient: Gradient(colors: [.white, .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(TriangleMask())
                .opacity(randomOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                        updateRandomOpacity()
                        isLightFlashing.toggle()
                    }
                }
                .ignoresSafeArea()
        }
        .saturation(0)
    }
    // GERA VALORES ALEATORIOS PARA EFEITO DE LUZ PISCANDO
    private func updateRandomOpacity() {
        randomOpacity = Double.random(in: 0...1)
    }

}

// MASCARA PARA LUZ EM FORMATO DE TRIANGULO
struct TriangleMask: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: geometry.size.width/2, y: -100))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))// / 1.5))
                path.addLine(to: CGPoint(x: 0, y: geometry.size.height ))/// 1.5))
            }
            .fill(Color.white)
        }
    }
}

#Preview {
    LampView()
}

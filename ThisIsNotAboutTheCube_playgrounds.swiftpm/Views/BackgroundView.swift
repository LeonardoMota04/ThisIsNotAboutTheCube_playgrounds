import SwiftUI

// BEHIND THE CUBE
struct PhaseBackgroundView: View {
    @EnvironmentObject private var vc: ViewController
    @State private var backgroundOffset: CGFloat = 0
    @State private var lampOpacity: Double = 0
   
    var body: some View {
        ZStack { // zstack for background + lamp
            // BACKGROUND
            ForEach(0..<vc.cubePhases.count, id: \.self) { index in
                GeometryReader { geometry in
                    vc.cubePhases[index].backgroundColor
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: CGFloat(index) * geometry.size.width)
                }
            }
            .offset(x: -(backgroundOffset) * UIScreen.main.bounds.width)
            .onChange(of: vc.currentPhaseIndex) { newValue in
                if newValue == 5 {
                    // Animar apenas na transição da fase 4 para a fase 5
                    withAnimation(.easeInOut(duration: 8)) {
                        print("NOVA FASE: \(newValue)")
                        backgroundOffset = CGFloat(newValue)
                    }
                } else {
                    // Sem animação para as outras transições
                    backgroundOffset = CGFloat(newValue)
                }
            }
                
            
            // 2D LAMP
            LampView()
                .opacity(lampOpacity)
        }
        .onChange(of: vc.finishedOnboarding) { _ in
            // AFTER 8 SECONDS OF FINISHED ONBOARDING, LAMP TURNS ON
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation(.easeIn(duration: 1)) {
                    lampOpacity = 1
                }
            }
        }
        
        .onChange(of: vc.currentPhaseIndex) { newValue in
            if newValue == 1 { // this is for the return of the user
                withAnimation(.easeIn(duration: 1)) {
                    lampOpacity = 1
                }
            }
            // lights turn of when phase 5 (acceptance) comes in
            if newValue == 5 {
                withAnimation(.easeOut(duration: 2.0)) {
                    lampOpacity = 0
                }
            }
        }
    }
}

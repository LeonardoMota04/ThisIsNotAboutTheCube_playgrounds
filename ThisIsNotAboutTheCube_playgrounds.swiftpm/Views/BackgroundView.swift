import SwiftUI



struct PhaseBackgroundView: View {
    @ObservedObject private var vc: ViewController
    @State private var backgroundOffset: CGFloat = 0
    
    init(vc: ViewController) {
        self.vc = vc
    }
    
    var body: some View {
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
    }
}

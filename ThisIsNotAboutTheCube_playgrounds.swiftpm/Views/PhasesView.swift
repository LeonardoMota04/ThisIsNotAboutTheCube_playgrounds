import SwiftUI
import SceneKit

struct PhasesView: View {
    @EnvironmentObject var vc: ViewController
    
    @State private var titleLabel: String = ""
    @State private var subtitleLabel: String = ""
    @State private var actionLabel: String = ""
    @State private var imageScale: CGFloat = 1.0
    @State private var headerOpacity: Double = 0.0
    @State private var actionLabelOpacity: Double = 0.0

    @State private var titleOffsetX: CGFloat = -UIScreen.main.bounds.width
    @State private var subtitleOffsetX: CGFloat = UIScreen.main.bounds.width
    @State private var textColor: Color = AppColor.bg_white.color
    
    
    
    var body: some View {
        let cfURL = Bundle.main.url(forResource: "fffforward", withExtension: "ttf")
        let _ = CTFontManagerRegisterFontsForURL(cfURL! as CFURL, CTFontManagerScope.process, nil)
        
        VStack (spacing: 20){
            /// Title
            Text(titleLabel)
                .font(Font.custom("fffforward", size: 50))
                .foregroundStyle(textColor)
                .opacity(headerOpacity)
                //.offset(x: titleOffsetX) // Adicionando deslocamento horizontal

            /// subtitle
            Text(subtitleLabel)
                .font(.system(size: 25))
                .multilineTextAlignment(.center)
                .frame(maxWidth: UIScreen.main.bounds.width / 1.2)
                .foregroundStyle(AppColor.bg_white.color)
                .opacity(headerOpacity)
                //.offset(x: subtitleOffsetX) // Adicionando deslocamento horizontal

            Spacer()

            /// Action Label
            VStack(spacing: 10) {
                Text(actionLabel)
                    .font(Font.custom("fffforward", size: 25))
                    .foregroundStyle(textColor)
                    .opacity(actionLabelOpacity)
                    .padding(.bottom, 100)
                Text("\(vc.numOfMovements) / \(vc.currentPhase?.movementsRequired ?? 0)")
                    .font(Font.custom("fffforward", size: 20))
                    .foregroundStyle(textColor)
                    .opacity(actionLabelOpacity)
            }
            
        }
        .padding()
        
        
       
        
        // MARK: - ON APPEAR
        .onAppear {
            titleLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase!.title
            subtitleLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase!.subtitle
            actionLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase!.actionLabel
        }
        
        // MARK: - ON CHANGE OF
        .onChange(of: vc.currentPhaseIndex) { newPhase in
            if newPhase == 5 {
                withAnimation(.easeInOut(duration: 5)) {
                    textColor = .black
                }
            }
            
            
            //withAnimation(.easeInOut(duration: 2)) {
            titleLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase!.title
            actionLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase!.actionLabel
            subtitleLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase!.subtitle
                
            //}
            
            // Animação de entrada da esquerda para o título
            withAnimation(.interactiveSpring(duration: 1.0)) {
                titleOffsetX = 0
            }

            // Aguarde um pouco antes de começar a animação do subtítulo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Animação de entrada da esquerda para o subtítulo
                withAnimation(.linear(duration: 1.0)) {
                    subtitleOffsetX = 0
                }
            }
            
            withAnimation(.easeIn(duration: 2.0)) {
                headerOpacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeIn(duration: 2.0)) {
                    self.actionLabelOpacity = 1
                }
            }

        }
    }
}

#Preview {
    ContentView()
}



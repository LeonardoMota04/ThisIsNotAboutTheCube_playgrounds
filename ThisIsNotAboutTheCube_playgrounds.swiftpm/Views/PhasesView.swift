import SwiftUI
import SceneKit

struct PhasesView: View {
    @ObservedObject private var vc: ViewController
    @State private var cubeBackgroundColor: Color = .clear
    @State private var titleLabel: String = ""
    @State private var subtitleLabel: String = ""
    @State private var actionLabel: String = ""
    @State private var imageScale: CGFloat = 1.0
    @State private var headerOpacity: Double = 0.0
    @State private var actionLabelOpacity: Double = 0.0

    @State private var titleOffsetX: CGFloat = -UIScreen.main.bounds.width
    @State private var subtitleOffsetX: CGFloat = UIScreen.main.bounds.width
    
    // phase 7
    @State private var finishedRotation = true
    @State private var buttonPhase7Opacity: Double = 0.0

    
    init(vc : ViewController) {
        self.vc = vc
    }
    
    var body: some View {

        let cfURL = Bundle.main.url(forResource: "fffforward", withExtension: "ttf")
        let _ = CTFontManagerRegisterFontsForURL(cfURL! as CFURL, CTFontManagerScope.process, nil)
        // INFORMATION
        
        VStack (spacing: 20){
            /// Title
            Text(titleLabel)
                .font(Font.custom("fffforward", size: 50))
                .foregroundStyle(.white)
                .opacity(headerOpacity)
                //.offset(x: titleOffsetX) // Adicionando deslocamento horizontal

            /// subtitle
            Text(subtitleLabel)
                .font(.system(size: 25))
                .multilineTextAlignment(.center)
                .frame(maxWidth: UIScreen.main.bounds.width / 1.2)
                .foregroundStyle(.white)
                .opacity(headerOpacity)
                //.offset(x: subtitleOffsetX) // Adicionando deslocamento horizontal

            
            Spacer()

            /// Action Label
            VStack(spacing: 10) {
                Text(actionLabel)
                    .font(Font.custom("fffforward", size: 20))
                    .foregroundStyle(.white)
                    .opacity(actionLabelOpacity)
                    .padding(.bottom, 100)
                //Text("\(vc.numOfMovements) / \(vc.currentPhase.movementsRequired)")
            }
            
        }
        .padding()
        
        // Button phase 7
        
        VStack {
            Button {
                if finishedRotation && vc.numOfMovementsPhase7 < 20 {
                    finishedRotation = false
                    rotateIceLayer(axis: SCNVector3(0, 1, 0), negative: false, cube: vc.rubiksCube, root: vc.rootNode) {
                        vc.numOfMovementsPhase7 += 1
                        finishedRotation = true
                    }
                }
            } label: {
                ZStack {
                    Rectangle()
                        .frame(width: 320, height: 120)
                        .foregroundStyle(Color(UIColor(named: "color_darkerGray")!))
                    Text("Persista")
                        .font(Font.custom("fffforward", size: 25))
                        .foregroundStyle(.white)
                }
            }
            .position(x: (UIScreen.main.bounds.width / 2), y: UIScreen.main.bounds.height - 200 )
            
            Text("\(vc.numOfMovementsPhase7) / 20")
                .font(Font.custom("fffforward", size: 25))
                .foregroundStyle(.white)
        }.opacity(buttonPhase7Opacity)
        
       
        
        // MARK: - ON APPEAR
        .onAppear {
            cubeBackgroundColor = vc.cubePhases.isEmpty ? .gray : vc.currentPhase.backgroundColor
            titleLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase.title
            subtitleLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase.subtitle
            actionLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase.actionLabel
        }
        
        // MARK: - ON CHANGE OF
        .onChange(of: vc.currentPhaseIndex) { newPhase in
            withAnimation(.snappy(duration: 1.0)) {
                cubeBackgroundColor = vc.cubePhases.isEmpty ? Color.gray : vc.currentPhase.backgroundColor
            }
            
            //withAnimation(.smooth(duration: 2.0)) {
                titleLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase.title
                actionLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase.actionLabel
                subtitleLabel = vc.cubePhases.isEmpty ? "empty" : vc.currentPhase.subtitle
                
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

            if newPhase == 7 {
                withAnimation(.easeIn(duration: 2.0)) {
                    buttonPhase7Opacity = 1
                }
            }
        }
    }
}

#Preview {
    ContentView()
}



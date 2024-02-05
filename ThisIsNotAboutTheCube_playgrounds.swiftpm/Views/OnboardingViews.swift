
import SwiftUI

// MARK: - BACK(cube) UI INFORMATION
struct Onboarding_backUI: View {
    @ObservedObject private var vc: ViewController

    var textNumber: Int
    @State private var xPosition1: Double = 125
    @State private var xPosition2: Double = 225
    @State private var divider: CGFloat = 2
    
    init(vc: ViewController, textNumber: Int) {
        self.vc = vc
        self.textNumber = textNumber
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(lineWidth: 5)
                .frame(width: UIScreen.main.bounds.width - 250, height: UIScreen.main.bounds.height / 1.5)
                .position(x: (UIScreen.main.bounds.width / 2) - xPosition1, y: UIScreen.main.bounds.height / divider)
                .foregroundStyle(Color(UIColor(named: "color_lighterGray")!))

            ZStack {
                Rectangle()
                    .foregroundStyle(Color(UIColor(named: "color_lighterGray")!))

                Text(textNumber == 1 ? "Olá, me chamo Leonardo e essa é minha cena para o Swift Student Challenge de 2024! Em um espaço etéreo, onde a luz dança com a sombra e a tristeza procura por picos de esperança, convido você para embarcar numa viagem de montanha russa para explorar a complexidade das emoções humanas durante as fases de batalhas internas contra os medos, traumas e dificuldades que todos compartilhamos. Cada movimento, cada rotação revelará as facetas de nossos sentimentos durante os momentos de queda e resiliência, trazendo o nosso lado mais humano: o que tem tem medo de mostrar seus medos."
                : "Cada fase é passada de forma automática conforme avanço do usuário \nAlgumas fases terão a câmera e/ou o cubo bloqueados.")
                    .font(.system(size: 25))
                    .bold()
                    .multilineTextAlignment(textNumber == 1 ? .trailing : .leading)
                    .padding(.horizontal, 20)
            }
            .frame(width: UIScreen.main.bounds.width - 450, height: UIScreen.main.bounds.height / 2)
            .position(x: (UIScreen.main.bounds.width / 2) + xPosition2, y: UIScreen.main.bounds.height / divider )

        }
        .onChange(of: textNumber) { newValue in
            withAnimation(.snappy(duration: 4.0)){
                xPosition1 = -xPosition1
                xPosition2 = -xPosition2
                if newValue == 3 {
                    divider = 0.5
                }
            }
        }
    }
}


// MARK: - FRONT(cube) UI INFORMATION
struct onboarding_frontUI: View {
    @ObservedObject private var vc: ViewController

    // BEFORE FIRST TOUCH
    @State private var isLoading = true
    @State private var pressToStartLabel = "Press to start"
    
    // UI-INFO ONBOARDING
    @State private var titleLabel: String = "Before we start..."
    @State private var subtitleLabel: String = ""
    @State private var actionLabel: String = ""
    @State private var textOpacity: Double = 0.0
    @State private var onboardingTextOpacity: Double = 0.0
    @State private var buttonOpacity: Double = 0.0
    
    // TIMER VARIABLES - ANIMATION
    private let loadingInterval: TimeInterval = 0.2
    @State private var timerIndex = 0
    
    // PRE PHASE 1
    @State private var bgHoleScale: Double = 0.0
    @State private var uiPhasesOpacity: Double = 0.0
    
    init(vc: ViewController) {
        self.vc = vc
    }
    
    var body: some View {
        ZStack {
            // MARK: - INFOS
            VStack {
                /// Title
                Text(titleLabel)
                    .font(Font.custom("fffforward", size: 50))
                    .foregroundStyle(Color(UIColor(named: "color_darkerGray")!))
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .opacity(!vc.madeTwoFingerMovements ? textOpacity : vc.readOnBoardingText2 ? buttonOpacity : 1)
                
                //if !vc.cameraIsMoving && !vc.madeTwoFingerMovements { // arrumar
                Image(vc.madeOneFingerMovements ? "twoFingerTouch" : "oneFingerTouch")
                    .padding(.top, 80)
                    .padding(.trailing, 30)
                    .opacity(textOpacity)
                //}
                
                Spacer()

                /// Action Label
                VStack(spacing: 40) {
                    Text(vc.madeOneFingerMovements ? "Rotate the camera" : "Interact with cube")
                        .font(Font.custom("fffforward", size: 25))
                        .foregroundStyle(Color(UIColor(named: "color_darkerGray")!))
                        .padding(.top, 50)
                    
                    Text("\(vc.numOfMovements) / \(vc.movementsToPassTutorial)")
                        .font(Font.custom("fffforward", size: 20))
                        .foregroundStyle(Color(UIColor(named: "color_middleGray")!))
                        .opacity(vc.madeOneFingerMovements ? 0 : 1)
                }
                .opacity(textOpacity)
                .padding(.bottom, 120)
            }
            
            Button("OK") {
                if !vc.readOnBoardingText1 {
                    vc.startFourthAnimation()
                    vc.readOnBoardingText1 = true
                } else {
                    vc.startFifthAnimation()
                    vc.readOnBoardingText2 = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                        vc.moveToNextPhase() // Starts the first phase
                    }
                }
            }
            .font(Font.custom("fffforward", size: 25))
            .foregroundStyle(Color(UIColor(named: "color_darkerGray")!))
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
            .opacity(buttonOpacity)
            
            // Press to start
            if isLoading && !vc.firstEverTouch {
                Text(pressToStartLabel)
                    .font(Font.custom("fffforward", size: 25))
                    .foregroundStyle(Color(UIColor(named: "color_middleGray")!))
                    .position(x: UIScreen.main.bounds.width - 250, y: UIScreen.main.bounds.height - 100)
            }
        }
        .onAppear {
            // timer
            Timer.scheduledTimer(withTimeInterval: loadingInterval, repeats: true) { _ in
                pressToStartLabel += "."
                
                if pressToStartLabel.contains("....") {
                    pressToStartLabel = "Press to start"
                }
            }
            
            
        }
        .onChange(of: vc.firstEverTouch) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation(.smooth(duration: 2.0)) {
                    textOpacity = 1.0
                }
            }
            
            
            
        
        }

        .onChange(of: vc.madeTwoFingerMovements) { _ in
            withAnimation(.smooth(duration: 5.0)) {
                textOpacity = 0.0
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation(.smooth(duration: 2.0)) {
                    onboardingTextOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.smooth(duration: 1.0)) {
                        buttonOpacity = 1
                    }
                }
            }
        }
        
        .onChange(of: vc.readOnBoardingText1) { _ in
            withAnimation(.smooth(duration: 1.0)) {
                buttonOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.smooth(duration: 1.0)) {
                    buttonOpacity = 1
                }
            }
        }
    }
}

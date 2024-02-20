import SwiftUI
import SceneKit

struct ContentView: View {
    // INITIALIZING VIEWCONTROLLER
    @EnvironmentObject var vc: ViewController

    // ONBOARDING
    @State private var isLoading = true
    private let loadingInterval: TimeInterval = 0.2
    @State private var pressToStartLabel = "Press to start"
    @State private var onboardingTextOpacity: Double = 0.0 // textos
    @State private var bgLinesScale: Double = 1.0
    @State private var bgHoleScale: Double = 0.0
    @State private var bgHoleOpacity: Double = 1.0
    
    // PHASES
    @State private var uiPhasesOpacity: Double = 0.0
    @State private var lampOpacity: Double = 0.0
    /// 2
    @State private var isGlitching = false
    /// 4
    @State private var saturationScene: Double = 1
    /// 5
    @State private var lastViewOpacity: Double = 0.0
    
    var body: some View {
        
        if let cfURL = Bundle.main.url(forResource: "fffforward", withExtension: "ttf") {
            let _ = CTFontManagerRegisterFontsForURL(cfURL as CFURL, CTFontManagerScope.process, nil)
        }
        
        if let cfURL2 = Bundle.main.url(forResource: "AlataRegular", withExtension: "ttf") {
            let _ = CTFontManagerRegisterFontsForURL(cfURL2 as CFURL, CTFontManagerScope.process, nil)
        }
            ZStack {
                // background color
                PhaseBackgroundView(vc: vc)
                    .ignoresSafeArea()
                
                
                
                // lamp
                LampView()
                    .opacity(lampOpacity)
                
                // cube
                CubeView()
                    .background(
                        vc.readOnBoardingText2
                        ? AnyView(SquaresViewFilled(scale: bgHoleScale, numOfSquares: 5).opacity(bgHoleOpacity))
                        : AnyView(SquaresViewStroke(scale: bgLinesScale, numOfSquares: 6))
                    )
                    .saturation(saturationScene)
                    //.blur(radius: isGlitching ? 5 : 0)
                    //.rotationEffect(isGlitching ? .degrees(45) : .zero)
                // phases view
                PhasesView()
                    .opacity(uiPhasesOpacity)
                // onboarding text
                OnboardingInformationView()
                    .opacity(onboardingTextOpacity)
                
                LastView()
                    .ignoresSafeArea()
                    .opacity(lastViewOpacity)
                
                // PULAR -------------------------
                Button("Pular") {
                    vc.moveText(text1: vc.textNode01!, text2: vc.textNode02!, by: SCNVector3(-0.5, -8, 50), duration: 1)

                    vc.readOnBoardingText2 = true
                    
                    if vc.currentPhaseIndex != 5 {
                        vc.moveToNextPhase()
                    } else {
                        vc.currentPhaseIndex = 0 
                    }
                    
                    isLoading = false
                                    //vc.setupCurrentPhase()
                }
                .font(Font.custom("AlataRegular", size: 25))
                .foregroundStyle(Color(UIColor(named: "color_darkerGray")!))
                .position(x: UIScreen.main.bounds.width / 10, y: UIScreen.main.bounds.height - 100)
                // PULAR -------------------------
                
                // Press to start
                if isLoading && !vc.firstEverTouch {
                    Text(pressToStartLabel)
                        .font(Font.custom("fffforward", size: 25))
                        .foregroundStyle(Color(UIColor(named: "color_middleGray")!))
                        .position(x: UIScreen.main.bounds.width - 250, y: UIScreen.main.bounds.height - 100)
                }
            }
            .onAppear {
                // timer to "press to start" animation
                Timer.scheduledTimer(withTimeInterval: loadingInterval, repeats: true) { _ in
                    pressToStartLabel += "."
                    if pressToStartLabel.contains("....") {
                        pressToStartLabel = "Press to start"
                    }
                }
            }
        
        // MARK: - MADE FIRST TOUCH EVER
            .onChange(of: vc.firstEverTouch) { newValue in
                // first time in the scene
                if !vc.finishedOnboarding {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.smooth(duration: 2.0)) {
                            onboardingTextOpacity = 1.0
                        }
                    }
                    withAnimation(.easeInOut(duration: 12)){
                        bgLinesScale = 8.0
                    }
                // reinitiation of the scene
                } else {
                    bgHoleScale = 0; bgHoleOpacity = 1
                    withAnimation(.easeInOut(duration: 6.0)) {
                        bgHoleScale = 8
                    }
                }
            }
        // MARK: - FINISHED ONBOARDING
            .onChange(of: vc.finishedOnboarding) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 6.0)) {
                        vc.startFirstAnimation()
                        bgHoleScale = 10
                        
                    }
                    // after 5 seconds the "hole" disappears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                        bgHoleOpacity = 0
                        withAnimation(.easeIn(duration: 6.0)) {
                            lampOpacity = 1
                        }
                    }

                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) { // 8S ORIGINAL
                    withAnimation(.easeIn(duration: 2.0)) {
                        uiPhasesOpacity = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.smooth(duration: 2.0)) {
                        onboardingTextOpacity = 0
                    }
                }
            }
        
        // MARK: - CHANGED PHASE
            .onChange(of: vc.currentPhaseIndex) { newValue in
                
                if newValue == 0 { // voltou ao inicio
                    withAnimation(.easeIn(duration: 2.0)) {
                        uiPhasesOpacity = 0
                    }
                    print("oioioioioioio")
                    withAnimation(.easeIn(duration: 2.0).delay(6)) {
                        lastViewOpacity = 1
                    }
                }
                
                if newValue == 1 {
                    print("TO AQUI POORRAAAAAAAA GREMIO")
                    //if vc.finishedOnboarding {
                        withAnimation(.easeIn(duration: 2.0)) {
                            lastViewOpacity = 0
                            uiPhasesOpacity = 1
                            // after 5 seconds the "hole" disappears
                            //DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                                bgHoleOpacity = 0
                                withAnimation(.easeIn(duration: 6.0)) {
                                    lampOpacity = 1
                                }
                            //}
                        }
                    //}
                }
                
                if newValue == 4 {
                    withAnimation(.easeIn(duration: 2.0)) {
                        saturationScene = 0
                    }
                }
                
                if newValue == 5 {
                    withAnimation(.easeOut(duration: 2.0)) {
                        lampOpacity = 0
                    }
                }
            }
            
        // MARK: - MADE A MOVEMENT
            .onChange(of: vc.numOfMovements) { newValue in
                if vc.currentPhaseIndex == 5 {
    //                let opacityAnimation = Double(16 - newValue) / 15
    //                withAnimation(.easeIn(duration: 1.0)) {
    //                    bgHoleOpacity = opacityAnimation
    //                }
                    
                    let saturationAnimation = Double(vc.numOfMovements) / 15
                    withAnimation(.easeIn(duration: 1.0)) {
                        saturationScene = saturationAnimation
                    }
                }
                
        }
       // }
    }
}





#Preview {
    ContentView()
}




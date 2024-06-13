import SwiftUI
import SceneKit

// MAIN VIEW THAT HOLDS BACKGROUND, CUBE, PHASES UI, ONBOARDING UI and LAST VIEW UI
struct ContentView: View {
    @EnvironmentObject var vc: ViewController

    // ONBOARDING
    @State private var isLoading = true
    private let loadingInterval: TimeInterval = 0.2
    @State private var pressToStartLabel = "Press to start"
    @State private var bgLinesScale: Double = 1.0
    @State private var bgHoleScale: Double = 0.0
    @State private var bgHoleOpacity: Double = 1.0
    @State private var bgLinesOpacity: Double = 1.0
    
    // VIEWS CONTROL VARIABLES
    @State private var showOnboardingView: Bool = false
    @State private var showLastView: Bool = false
    @State private var showCreditsButton: Bool = true
    @State private var onboardingViewOpacity: Double = 0.0
    @State private var openModalCredits: Bool = false

    // PHASES
    @State private var saturationScene: Double = 1
    @State private var lastViewOpacity: Double = 0.0
    
    var body: some View {
        if let cfURL = Bundle.main.url(forResource: "fffforward", withExtension: "ttf") {
            let _ = CTFontManagerRegisterFontsForURL(cfURL as CFURL, CTFontManagerScope.process, nil)
        }
            ZStack {
                // BACKGROUND
                PhaseBackgroundView()
                    .ignoresSafeArea()
                
                // CUBE REPRESENTABLE
                CubeView()
                    .background(SquaresView())
                    .saturation(saturationScene)
                    
                // PHASES
                switch vc.currentPhaseIndex {
                    // ONBOARDING / LAST VIEW
                    case 0:
                    if showCreditsButton { CreditsButton(vc: vc, isPresented: $openModalCredits) }
                    if showOnboardingView { OnboardingInformationView().ignoresSafeArea() }
                    if showLastView { LastView(showCreditsButton: $showCreditsButton).ignoresSafeArea() }
                        
                    // PHASES
                    default:
                        PhasesView()
                }
                
                // PRESS TO START LABEL
                if isLoading && !vc.firstEverTouch {
                    Text(pressToStartLabel)
                        .font(Font.custom("fffforward", size: 25))
                        .foregroundStyle(AppColor.color_middleGray.color)
                        .position(x: UIScreen.main.bounds.width - 250, y: UIScreen.main.bounds.height - 100)
                }
            }
            .sheet(isPresented: $openModalCredits) {CreditsView(isPresented: $openModalCredits)}
        
        // MARK: - ON APPEAR
        /// Timer to "press to start" label
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: loadingInterval, repeats: true) { _ in
                    pressToStartLabel += "."
                    if pressToStartLabel.contains("....") {
                        pressToStartLabel = "Press to start"
                    }
                }
            }
        
        // MARK: - MADE FIRST TOUCH EVER
            .onChange(of: vc.firstEverTouch) { newValue in
                if newValue == true {
                    showCreditsButton = false
                    // 1
                    if !vc.finishedOnboarding {
                        // lines get bigger
                        withAnimation(.easeInOut(duration: 12)){
                            bgLinesScale = 8.0
                        }
                        // onboarding view appear (5s delay)
                        withAnimation(.smooth(duration: 2).delay(5)){
                            showOnboardingView = true
                        }
                        
                    // 2 +
                    } else {
                        bgHoleScale = 0
                        bgHoleOpacity = 1
                        withAnimation(.easeInOut(duration: 4.0)) {
                            bgHoleScale = 10
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            bgHoleOpacity = 0
                        }
                        showLastView = false
                    }
                } else {
                    if vc.readText2 {
                        showCreditsButton = true
                    }
                }
            }
        
        // MARK: - FINISHED ONBOARDING
            .onChange(of: vc.finishedOnboarding) { _ in
                withAnimation(.easeIn(duration: 4.0).delay(2)) {
                    bgHoleScale = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    bgHoleOpacity = 0
                }
            }
        
        // MARK: - CHANGED PHASE
            .onChange(of: vc.currentPhaseIndex) { newValue in
                // Back to the beggining
                if newValue == 0 {
                    withAnimation(.easeOut(duration: 2.0)) {
                        showOnboardingView = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        showLastView = true
                    }
                }
                
                if newValue == 1 {
                    withAnimation(.easeIn(duration: 2.0)) {
                        lastViewOpacity = 0
                    }
                }
                
                if newValue == 4 {
                    withAnimation(.easeIn(duration: 2.0)) {
                        saturationScene = 0
                    }
                }
            }
            
        // MARK: - MADE A MOVEMENT
            .onChange(of: vc.numOfMovements) { _ in
                if vc.currentPhaseIndex == 5 {
                    let saturationAnimation = Double(vc.numOfMovements) / 15
                    withAnimation(.easeIn(duration: 1.0)) {
                        saturationScene = saturationAnimation
                    }
                }
        }
    }
}




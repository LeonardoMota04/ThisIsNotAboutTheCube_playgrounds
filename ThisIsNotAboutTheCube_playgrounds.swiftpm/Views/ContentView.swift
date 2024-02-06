//
//  MovementsView.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 22/12/23.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @ObservedObject private var vc = ViewController()

    // ONBOARDING
    @State private var isLoading = true
    private let loadingInterval: TimeInterval = 0.2
    @State private var pressToStartLabel = "Press to start"
    @State private var titleLabel: String = "Before we start..."
    @State private var textOpacity: Double = 0.0 // antes dos textos
    @State private var onboardingTextOpacity: Double = 0.0 // textos
    @State private var buttonOpacity: Double = 0.0
    @State private var bgLinesScale: Double = 1.0
    @State private var bgHoleScale: Double = 0.0
    @State private var bgHoleOpacity: Double = 1.0
    
    // PHASES
    @State private var uiPhasesOpacity: Double = 0.0
    /// 2
    @State private var isGlitching = false
    /// 4
    @State private var saturationScene: Double = 1
    @State private var backgroundOffset: CGFloat = 0
    
    var body: some View {
        
        if let cfURL = Bundle.main.url(forResource: "fffforward", withExtension: "ttf") {
            let _ = CTFontManagerRegisterFontsForURL(cfURL as CFURL, CTFontManagerScope.process, nil)
        }
        
        ZStack {
            // BACKGROUND
            ForEach(0..<vc.cubePhases.count, id: \.self) { index in
                GeometryReader { geometry in
                    PhaseBackgroundView(color: vc.cubePhases[index].backgroundColor)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: CGFloat(index) * geometry.size.width)
                }
            }
            .offset(x: -(backgroundOffset) * UIScreen.main.bounds.width)
            .onChange(of: vc.currentPhaseIndex) { newValue in
                withAnimation(.linear(duration: 2)) {
                    print("NOVA FASE: \(newValue)")
                    backgroundOffset = CGFloat(newValue)
                }
            }
            
            
            // MARK: - TEXTOS
            OnboardingInformationView(textNumber: !vc.readOnBoardingText1 ? 1 : !vc.readOnBoardingText2 ? 2 : 3)
                .opacity(onboardingTextOpacity)
            PhasesView(vc: vc)
                .opacity(uiPhasesOpacity)
            
            // MARK: - CUBO
            CubeView(viewController: vc)
                .background(
                    vc.readOnBoardingText2
                    ? AnyView(SquaresViewFilled(scale: bgHoleScale, numOfSquares: 5).opacity(bgHoleOpacity))
                    : AnyView(SquaresViewStroke(scale: bgLinesScale, numOfSquares: 6))
                )
                .saturation(saturationScene)
                .blur(radius: isGlitching ? 5 : 0)
                .rotationEffect(isGlitching ? .degrees(180) : .zero)
            
            Button("PULAR") {
                vc.moveText(text1: vc.textNode01!, text2: vc.textNode02!, by: SCNVector3(0, 0, 50), duration: 1)
                vc.readOnBoardingText2 = true
                vc.moveToNextPhase()
                isLoading = false
                                //vc.setupCurrentPhase()
            }
            .font(Font.custom("fffforward", size: 25))
            .foregroundStyle(Color(UIColor(named: "color_darkerGray")!))
            .position(x: UIScreen.main.bounds.width / 10, y: UIScreen.main.bounds.height - 100)
            
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.smooth(duration: 2.0)) {
                    textOpacity = 1.0
                }
            }
            
         
            withAnimation(.easeInOut(duration: 12)){
                bgLinesScale = 8.0
            }
            
        
        }

        .onChange(of: vc.madeTwoFingerMovements) { _ in
            withAnimation(.smooth(duration: 5.0)) {
                textOpacity = 0.0
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
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
        
        .onChange(of: vc.readOnBoardingText2) { _ in
            withAnimation(.smooth(duration: 1.0)) {
                buttonOpacity = 0
            }
            
//            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//                guard timerIndex < "THIS IS NOT ABOUT THE CUBE".count + 2 else {
//                    return
//                }
//
//                let nextLetter = titleLabel.index(titleLabel.startIndex, offsetBy: timerIndex)
//
//                titleLabel += String("\n\nTHIS IS NOT ABOUT THE CUBE"[nextLetter])
//
//                timerIndex += 1
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 6.0)) {
                    vc.startFirstAnimation()
                    bgHoleScale = 10
                }
                // after 5 seconds the "hole" disappears
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    bgHoleOpacity = 0
                }

            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) { // 8S ORIGINAL
                withAnimation(.easeIn(duration: 2.0)) {
                    uiPhasesOpacity = 1
                }
            }
        }
        // CHANGE OF PHASE
        .onChange(of: vc.currentPhaseIndex) { newValue in
            if newValue == 2 {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    isGlitching.toggle()
                }
            } else {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isGlitching = false
                }
            }
            
            if newValue == 4 {
                withAnimation(.easeIn(duration: 2.0)) {
                    saturationScene = 0
                }
            }
        }
        
        // CHANGE OF NUM OF MOVEMENTS
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
    }
}


// MARK: - Onboarding information
struct OnboardingInformationView: View {
    var textNumber: Int
    @State private var xPosition1: Double = 125
    @State private var xPosition2: Double = 225
    @State private var divider: CGFloat = 2
    
    init(textNumber: Int) {
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


#Preview {
    //ContentView()
    ContentView()
}


struct GlitchTextEffect: View {
    @State private var isGlitching = false

    var body: some View {
        Text("Glitch Effect")
            .font(.system(size: 30))
            .foregroundColor(.green)
            .opacity(isGlitching ? 0.5 : 1.0)
            .blur(radius: isGlitching ? 5 : 0) // Adiciona um efeito de desfoque durante o glitch
            .animation(Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true))
            .onAppear() {
                isGlitching.toggle()
            }
    }
}

struct ContentView2: View {
    var body: some View {
        VStack {
            GlitchTextEffect()
                .frame(width: 200, height: 50)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}

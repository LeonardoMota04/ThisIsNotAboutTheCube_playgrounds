import SwiftUI

struct OnboardingFirstPartView : View {
    @EnvironmentObject var vc: ViewController
    @State private var imageAssetFingerGestureName: String = "oneFingerTouch"

    var body: some View {
        // ONBOARDING FIRST PART
        VStack {
            Spacer()
            Image(imageAssetFingerGestureName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)  // Ajuste conforme necessário
                .padding(.trailing, 30)
                //.opacity(textOpacity)
                .onChange(of: vc.madeOneFingerMovements) { _ in
                    withAnimation(.linear(duration: 0.5)) {
                        self.imageAssetFingerGestureName = "twoFingerTouch"
                    }
                }
            
            Spacer()

            /// Action Label + x / y
            VStack(spacing: 40) {
                Text(vc.madeOneFingerMovements
                     ? "Rotate the camera"
                     : "Interact with cube")
                    .font(Font.custom("fffforward", size: 25))
                    .foregroundStyle(Color(UIColor(named: "color_darkerGray")!))
                    .padding(.top, 50)
                
                Text("\(vc.numOfMovements) / \(vc.movementsToPassTutorial)")
                    .font(Font.custom("fffforward", size: 20))
                    .foregroundStyle(Color(UIColor(named: "color_middleGray")!))
                    .opacity(vc.madeOneFingerMovements ? 0 : 1)
            }
            //.opacity(textOpacity)
            .padding(.top, 150)
            Spacer()
        }
    }
}


struct OnboardingSecondPartView: View {
    @EnvironmentObject var vc: ViewController 
    @State private var xPosition1: Double = 125
    @State private var xPosition2: Double = 225
    @State private var divider: CGFloat = 2
    @State private var buttonOpacity: Double = 1
    
    var body: some View {
        // ONBOARDING SECOND PART
        ZStack {
            Rectangle()
                .stroke(lineWidth: 5)
                .frame(width: UIScreen.main.bounds.width - 250, height: UIScreen.main.bounds.height / 1.5)
                .position(x: (UIScreen.main.bounds.width / 2) - xPosition1, y: UIScreen.main.bounds.height / divider)
                .foregroundStyle(Color(UIColor(named: "color_lighterGray")!))

            ZStack {
                Rectangle()
                    .foregroundStyle(Color(UIColor(named: "color_lighterGray")!))

                Text(!vc.readOnBoardingText1 ? "Hello, my name is Leonardo, and this is my scene for the Swift Student Challenge 2024! \nIn an ethereal space where light dances with shadow and sorrow seeks peaks of hope, I invite you to embark on a roller coaster journey to explore the complexity of human emotions during the phases of internal battles throughout each stage of grief. Every movement, every rotation will unveil the facets of our feelings during moments of descent and resilience, revealing our most human side: the one afraid of not being able to move forward."
                : "- Each phase is automatically transitioned as the user progresses. \n\n- Some phases will have the camera and/or the cube locked.")
                    .font(Font.custom("AlataRegular", size: 25))
                    .bold()
                    .multilineTextAlignment(!vc.readOnBoardingText1 ? .trailing : .leading)
                    .padding(.horizontal, 20)
            }
            .frame(width: UIScreen.main.bounds.width - 450, height: UIScreen.main.bounds.height / 2)
            .position(x: (UIScreen.main.bounds.width / 2) + xPosition2, y: UIScreen.main.bounds.height / divider )
            
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
        }
        .onChange(of: vc.readOnBoardingText1) { _ in
            withAnimation(.snappy(duration: 4.0)){
                xPosition1 = -xPosition1
                xPosition2 = -xPosition2
            }
            withAnimation(.smooth(duration: 0.5)) {
                buttonOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.smooth(duration: 1.0)) {
                    buttonOpacity = 1
                }
            }
        }
        
        .onChange(of: vc.finishedOnboarding) { _ in
            withAnimation(.snappy(duration: 4.0)){
                xPosition1 = -xPosition1
                xPosition2 = -xPosition2
                divider = 0.5
            }
            withAnimation(.smooth(duration: 0.5)) {
                buttonOpacity = 0
            }
            
        }
    }
}
struct OnboardingInformationView: View {
    @EnvironmentObject var vc: ViewController
    @State private var viewOpacity: Double = 0
    
    
    init() {
        if let cfURL = Bundle.main.url(forResource: "AlataRegular", withExtension: "ttf") {
            let _ = CTFontManagerRegisterFontsForURL(cfURL as CFURL, CTFontManagerScope.process, nil)
        } else {
            print("Unable to find the font ALATA")
        }
    }
    
    var body: some View {
       
        ZStack(alignment: .top) {
            Text("Before we start...")
                .font(Font.custom("fffforward", size: 50))
                .foregroundStyle(Color(UIColor(named: "color_darkerGray")!))
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            if !vc.madeTwoFingerMovements {
                OnboardingFirstPartView()
                    .transition(.opacity.animation(.easeInOut(duration: 2).delay(3)))
            } else {
                OnboardingSecondPartView()
                    .transition(.opacity.animation(.easeInOut(duration: 2).delay(8)))
            }
        }
        
    }
}

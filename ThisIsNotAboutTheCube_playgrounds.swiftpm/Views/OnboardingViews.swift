import SwiftUI

// ONBOARDING UI VIEWS
struct OnboardingInformationView: View {
    @EnvironmentObject var vc: ViewController
    @State private var offSetTitle: Double = 0
    
    var body: some View {
       
        ZStack(alignment: .top) {
            Text("Before we start...")
                .font(Font.custom("fffforward", size: 50))
                .foregroundStyle(AppColor.color_darkerGray.color)
                .multilineTextAlignment(.center)
                .padding(.top, 45)
                .offset(y: offSetTitle)
                .onChange(of: vc.readOnBoardingText2) { _ in
                    withAnimation(.easeInOut(duration: 1)) {
                        offSetTitle -= 300
                    }
                }
            
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

// MARK: - FIRST PART
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
                    .foregroundStyle(AppColor.color_darkerGray.color)
                    .padding(.top, 50)
                
                Text("\(vc.numOfMovements) / \(vc.movementsToPassTutorial)")
                    .font(Font.custom("fffforward", size: 20))
                    .foregroundStyle(AppColor.color_middleGray.color)
                    .opacity(vc.madeOneFingerMovements ? 0 : 1)
            }
            .padding(.top, 150)
            Spacer()
        }
    }
}

// MARK: - SECOND PART
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
                .foregroundStyle(AppColor.color_thirdGray.color)

            ZStack {
                Rectangle()
                    .foregroundStyle(AppColor.color_lighterGray.color)

                Text(!vc.readOnBoardingText1 ? "Hello, my name is Leonardo, and this is my scene for the Swift Student Challenge 2024! \nIn an ethereal space where light dances with shadow and sorrow seeks peaks of hope, I invite you to embark on a roller coaster journey to explore the complexity of human emotions during the phases of internal battles throughout each stage of grief. Every movement, every rotation will unveil the facets of our feelings during moments of descent and resilience, revealing our most human side: the one afraid of not being able to move forward."
                : "- Each phase is automatically transitioned as the user progresses. \n\n- Some phases will have the camera and/or the cube locked.")
                    .multilineTextAlignment(!vc.readOnBoardingText1 ? .trailing : .leading)
                    .padding(.horizontal, 20)
                    .foregroundStyle(AppColor.color_darkerGray.color)
                    .font(.system(size: 25))
            }
            .frame(width: UIScreen.main.bounds.width - 450, height: UIScreen.main.bounds.height / 2)
            .position(x: (UIScreen.main.bounds.width / 2) + xPosition2, y: UIScreen.main.bounds.height / divider )
            
            HStack {
                // < BUTTON
                Button {
                    vc.adjustCameraPositionPhase05_2()
                    vc.readOnBoardingText1 = false
                } label: {
                    Text("<")
                }
                .font(Font.custom("fffforward", size: 50))
                .opacity(!vc.readOnBoardingText1 ? 0 : 1)
                .disabled(!vc.readOnBoardingText1)
                
                Spacer()
                
                // > BUTTON / FINISH BUTTON
                Button {
                    if !vc.readOnBoardingText1 {
                        vc.startFourthAnimation()
                        vc.readOnBoardingText1 = true
                    } else {
                        // MARK: - INITIATES SCENE
                        vc.startFifthAnimation()
                        vc.readOnBoardingText2 = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            setupLowLights(ambientLight: vc.ambientLight, omniLight: vc.omniLight, root: vc.rootNode, camera: vc.cameraNode)
                            vc.shuffleCube(times: 20) {
                                vc.canRotateCube = true
                                vc.cameraIsMoving = false
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            vc.moveToNextPhase() // Starts the first phase
                        }
                    }
                } label: {
                    Text(!vc.readOnBoardingText1 ? ">" : "START")
                        .font(!vc.readOnBoardingText1
                              ? Font.custom("fffforward", size: 50)
                              : Font.custom("fffforward", size: 30))
                }
            }
            .padding(.horizontal, 150)
            .padding(.bottom, -30)
            .foregroundStyle(AppColor.color_darkerGray.color)
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
            .opacity(buttonOpacity)
        }
        .onChange(of: vc.readOnBoardingText1) { _ in
            buttonOpacity = 0
            
            withAnimation(.snappy(duration: 4.0)){
                xPosition1 = -xPosition1
                xPosition2 = -xPosition2
            }
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.smooth(duration: 1.0)) {
                    buttonOpacity = 1
                }
            }
        }
        .onChange(of: vc.finishedOnboarding) { _ in
            buttonOpacity = 0

            withAnimation(.snappy(duration: 4.0)){
                xPosition1 = -xPosition1
                xPosition2 = -xPosition2
                divider = 0.5
            }
        }
    }
}

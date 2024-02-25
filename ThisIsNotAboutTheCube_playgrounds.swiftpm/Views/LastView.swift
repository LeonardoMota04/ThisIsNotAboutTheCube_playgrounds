import SwiftUI

// LAST UI VIEWS
struct LastView: View {
    @EnvironmentObject var vc: ViewController
    @State private var xPosition1: Double = 1200 // 125
    @State private var xPosition2: Double = 1200 // 225
    @State private var divider: CGFloat = 2
    @State private var buttonOpacity: Double = 1
    @State private var readText1: Bool = false
    @State private var readText2: Bool = false
    
    @Binding var showCreditsButton: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(lineWidth: 5)
                .frame(width: UIScreen.main.bounds.width - 250, height: UIScreen.main.bounds.height / 1.5)
                .position(x: (UIScreen.main.bounds.width / 2) + xPosition1, y: UIScreen.main.bounds.height / divider)
                .foregroundStyle(AppColor.color_thirdGray.color)

            ZStack {
                Rectangle()
                    .foregroundStyle(AppColor.color_lighterGray.color)

                Text(!readText1 ? "\"It is very important that you only do what you love to do. You may be poor, you may lose your car, you may have to move into a shabby place to live, but you will totally live. And at the end of your days you will bless your life because you have done what you came here to do.\" \n\n\(Text("- Elisabeth Kübler-Ross (1926-2004)").bold())"
                     : "Elisabeth was a Swiss-American psychiatrist who theorized the five stages of grief in her book \(Text("'On Death and Dying' (1969)").bold()). \n\nShe emphasized that the stages are not a rigid model and highlighted the \(Text("uniqueness of each grieving process").bold()). \n\nEvery new interaction with this scene brings a little of what Elisabeth said, with \(Text("3,674,160 possible states, the cube reminds you that in reality...").bold())")

                .foregroundStyle(AppColor.color_darkerGray.color)
                .font(.system(size: 25))
                .multilineTextAlignment(readText1 ? .trailing : .leading)
                .padding(.horizontal, 20)
            }
            .frame(width: UIScreen.main.bounds.width - 450, height: UIScreen.main.bounds.height / 2)
            .position(x: (UIScreen.main.bounds.width / 2) - xPosition2, y: UIScreen.main.bounds.height / divider )
            
            // Buttons
            HStack {
                 // <
                Button("<") {
                    vc.startFourthAnimation()
                    withAnimation(.smooth(duration: 2.0)) {
                        xPosition1 = 125
                        xPosition2 = 225
                    }
                    readText1 = false
                }
                .font(Font.custom("fffforward", size: 50))
                .opacity(!readText1 ? 0 : 1)
                .disabled(!readText1)
                
                Spacer()
                
                // > / finish
                Button(!readText1 ? ">" : "FINISH") {
                    if !readText1 {
                        vc.adjustCameraPositionPhase05_2()
                        readText1 = true
                    } else {
                        vc.adjustCameraPositionPhase05_3()
                        readText2 = true
                    }
                }
                .font(!readText1
                      ? Font.custom("fffforward", size: 50)
                      : Font.custom("fffforward", size: 30))
            }
            .padding(.horizontal, 150)
            .padding(.bottom, -30)
            .foregroundStyle(AppColor.color_darkerGray.color)
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
            .opacity(buttonOpacity)
        }
        // MARK: - ON APPEAR
        .onAppear {
            withAnimation(.smooth(duration: 2.0)) {
                xPosition1 = 125
                xPosition2 = 225
            }
        }
        
        // MARK: - READ TEXT 1
        .onChange(of: readText1) { newValue in
            if newValue == true {
                withAnimation(.snappy(duration: 4.0)){
                    xPosition1 = -xPosition1
                    xPosition2 = -xPosition2
                }
                withAnimation(.smooth(duration: 0 )) {
                    buttonOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation(.smooth(duration: 1.0)) {
                        buttonOpacity = 1
                    }
                }
            }
        }
        
        // MARK: - READ TEXT 2
        .onChange(of: readText2) { newValue in
            if newValue == true {
                withAnimation(.snappy(duration: 4.0)){
                    xPosition1 = -xPosition1
                    xPosition2 = -xPosition2
                    divider = 0.5
                }
                withAnimation(.smooth(duration: 0)) {
                    buttonOpacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    showCreditsButton = true
                }
            }
        }
        .onChange(of: vc.currentPhaseIndex) { newPhase in
            if newPhase == 1 {
                // when phase 1 is entered, we reset values
                xPosition1 = 125
                xPosition2 = 225
                divider = 2
                readText1 = false
                readText2 = false
                buttonOpacity = 1
            }
        }
    }
}

import SwiftUI
import SceneKit

// PHASES UI VIEW
struct PhasesView: View {
    @EnvironmentObject var vc: ViewController
    
    // TEXTS
    @State private var titleLabel: String = ""
    @State private var actionLabel: String = ""
    @State private var actionLabelOpacity: Double = 1
    @State private var titleOffsetY: CGFloat = -UIScreen.main.bounds.height
    @State private var rotationBackgroundTitle: Double = 5
    @State private var actionLabelOffsetY: CGFloat = UIScreen.main.bounds.height
    @State private var titleTextColor: Color = AppColor.color_lighterGray.color
    @State private var textColor: Color = AppColor.color_lighterGray.color
    
    var body: some View {
        let cfURL = Bundle.main.url(forResource: "fffforward", withExtension: "ttf")
        let _ = CTFontManagerRegisterFontsForURL(cfURL! as CFURL, CTFontManagerScope.process, nil)
        
        VStack (spacing: 20){
            /// Title
            ZStack {
                Rectangle()
                    .frame(width: 350, height: 100)
                    .rotationEffect(.degrees(rotationBackgroundTitle))
                    .foregroundStyle(AppColor.color_darkerGray.color)
                    .offset(y: vc.currentPhaseIndex != 5 ? titleOffsetY 
                            : withAnimation(.easeInOut(duration: 2)) {-UIScreen.main.bounds.height} )
                Text(titleLabel)
                    .font(Font.custom("fffforward", size: 60))
                    .foregroundStyle(titleTextColor)
                    .offset(y: titleOffsetY)
                    
            }
            
            Spacer()

            /// Action Label
            VStack(spacing: 10) {
                Text("\"\(Text(actionLabel))\"")
                    .font(Font.custom("fffforward", size: 25))
                    .multilineTextAlignment(.center)
                    .frame(width: 1000)
                    .foregroundStyle(textColor)
                
                Text("\(vc.numOfMovements) / \(vc.currentPhase?.movementsRequired ?? 0)")
                .font(Font.custom("fffforward", size: 50))
                .foregroundStyle(AppColor.color_middleGray.color)
                .rotation3DEffect(
                    .degrees(45),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .center
                )
                
            }
            .opacity(actionLabelOpacity)
            .offset(y: actionLabelOffsetY)
            .padding(.bottom, 20)
        }
        .padding()
        
        // MARK: - ON APPEAR
        .onAppear {
            // GETTERS
            titleLabel = vc.currentPhase!.title
            actionLabel = vc.currentPhase!.actionLabel
            
            withAnimation(.easeInOut(duration: 3).delay(2)) {
                titleOffsetY = 0
            }
            withAnimation(.easeInOut(duration: 3).delay(3)) {
                actionLabelOffsetY = 0
            }
        }
        
        // MARK: - ON CHANGE OF
        .onChange(of: vc.currentPhaseIndex) { newPhase in
            // PHASE 5
            if newPhase == 5 {
                withAnimation(.easeInOut(duration: 5)) {
                    // Change text color
                    titleTextColor = .black
                    textColor = .black
                    
                    titleLabel = vc.currentPhase!.title
                    actionLabel = vc.currentPhase!.actionLabel
                }
                
            // 1, 2, 3, 4
            } else {
                // Text go up, change, then comes back down
                withAnimation(.easeInOut(duration: 2)) {
                    // old text up
                    titleOffsetY = -UIScreen.main.bounds.height
                    actionLabelOffsetY = UIScreen.main.bounds.height
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        titleLabel = vc.currentPhase!.title
                        actionLabel = vc.currentPhase!.actionLabel
                        rotationBackgroundTitle = -(rotationBackgroundTitle)
                    
                        // new text down
                        withAnimation(.easeInOut(duration: 2)) {
                            titleOffsetY = 0
                            actionLabelOffsetY = 0
                        }
                    }
                }
            }
        }
    }
}

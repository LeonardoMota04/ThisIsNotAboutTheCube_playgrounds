import SwiftUI
import SceneKit

// CREDITS VIEW
struct CreditsView: View {
    var body: some View {
        if let cfURL = Bundle.main.url(forResource: "fffforward", withExtension: "ttf") {
            let _ = CTFontManagerRegisterFontsForURL(cfURL as CFURL, CTFontManagerScope.process, nil)
        }
        ZStack {
            AppColor.color_middleGray.color.ignoresSafeArea()
            
            VStack(spacing: 20){
                // TITLE
                ZStack {
                    Rectangle()
                        .frame(width: 350, height: 100)
                        .rotationEffect(.degrees(5))
                        .foregroundStyle(AppColor.color_darkerGray.color)
                    Text("CREDITS")
                        .font(Font.custom("fffforward", size: 60))
                        .foregroundStyle(AppColor.bg_white.color)
                }
                .padding(.top, 20)
               
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("ABOUT")
                        .font(Font.custom("fffforward", size: 20))
                        .foregroundStyle(AppColor.color_darkerGray.color)
                    Text("\"This is Not About The Cube\" is an interactive scene that utilizes a simple Rubiks Cube to represent different emotions experienced during the stages of grief.")
                        .font(Font.custom("fffforward", size: 20))
                        .foregroundStyle(AppColor.bg_white.color)
                }
                    .padding(.top, 30)
                
                Spacer()
                // TEXTS
                VStack(alignment: .leading, spacing: 10) {
                    Text("ASSETS")
                        .font(Font.custom("fffforward", size: 20))
                        .foregroundStyle(AppColor.color_darkerGray.color)
                    Text("- All images assets were made by me")
                        .font(Font.custom("fffforward", size: 20))
                        .foregroundStyle(AppColor.bg_white.color)
                    Text("- Font used: \"FFF Forward\" provided by Fonts For Flash Inc")
                        .font(Font.custom("fffforward", size: 20))
                        .foregroundStyle(AppColor.bg_white.color)
                }
                Spacer()
                Text("A project by: Leonardo Pereira Mota")
                    .font(Font.custom("fffforward", size: 15))
                    .foregroundStyle(AppColor.color_darkerGray.color)
            }
            .padding()
        }
    }
}

// CREDITS BUTTON
struct CreditsButton: View {
    @ObservedObject var vc: ViewController
    @Binding var isPresented: Bool
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(AppColor.color_middleGray.color)
                    .rotationEffect(.degrees(10))
                Text("C")
                    .font(Font.custom("fffforward", size: 30))
                    .foregroundStyle(AppColor.bg_white.color)
            }
        }
        .position(x: 100, y: 50)
    }
}

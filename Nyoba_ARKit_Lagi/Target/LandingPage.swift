//
//  LandingPage.swift
//  Nyoba_ARKit_Lagi
//
//  Created by Jonathan Andrew Yoel on 29/04/24.
//

import SwiftUI

struct LandingPage: View {
    var body: some View {
        ZStack{
            Color(.green)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                Image("ImageLanding") .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 361, height: 550, alignment: .center)
                Text("MONARA")
                    .font(
                    Font.custom("Telugu MN", size: 64)
                        .weight(.bold)
                    )
                    .kerning(8)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
        }
           
    }
}

#Preview {
    LandingPage()
}

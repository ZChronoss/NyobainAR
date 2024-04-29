//
//  Page1AR.swift
//  Nyoba_ARKit_Lagi
//
//  Created by Jonathan Andrew Yoel on 29/04/24.
//

import SwiftUI

struct Page1AR: View {
    @State var isForestTap = false
    @State var isMountainTap = false
    
    var body: some View {
        //Location for forest
        NavigationView {
            ZStack {
                //Location for forest
                VStack {
                    NavigationLink(destination: CustomARViewRepresentable()) {
                        Image("LocationForest")
                            .position(x:100.0, y:532.0)
                            .padding()
//                            .onTapGesture {
//                                isForestTap.toggle()
                        }
                    }

                
                //Location for Mountain
                VStack {
                    Image("LocationMountain")
                        .position(x: 249.0, y: 156.0)
                        .padding()
                        .onTapGesture {
                            isMountainTap.toggle()
                        }
                }
                
            }
            .padding()
        .background(Image("ImageBackground"))
        }
    }
}

#Preview {
    Page1AR()
}

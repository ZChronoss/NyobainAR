//  Page1AR.swift
//  Nyoba_ARKit_Lagi
//
//  Created by Jonathan Andrew Yoel on 29/04/24.
//

import SwiftUI

struct Page1AR: View {
    
    @Environment(\.verticalSizeClass) var heighSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        //Ini Iphone 15 Portrait
        if widthSizeClass == .compact{
            //Ini Iphone portrait
            if heighSizeClass == .regular{
                NavigationView {
                      ZStack {
                          //Location for forest
                          VStack {
                              NavigationLink(destination: CustomARViewRepresentable()) {
                                  Image("LocationForest")
                                      .resizable()
                                      .scaledToFit()
                                      .padding()
                                  }
                              .frame(width: 105, height: 150)
                              .position(x:100.0, y:532.0)
                              }
                      }
                      .background(
                         Image("ImageBackground").frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                      )
                }
            }
            //ini iphone landscape
            else if heighSizeClass == .compact{
                NavigationView {
                      ZStack {
                          //Location for forest
                          VStack {
                              NavigationLink(destination: CustomARViewRepresentable()) {
                                  Image("LocationForest")
                                      .resizable()
                                      .scaledToFit()
                                      .padding()
                                  }
                              .frame(width: 105, height: 150)
                              .position(x:150.0, y:266.0)
                              }
                      }
                      .background(
                         Image("ImageBackground").frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                      )
                }
            }
        }
        //Ini untuk ipad
        else if widthSizeClass == .regular{
            NavigationStack {
                  ZStack {
                      //Location for forest
                      VStack {
                          NavigationLink(destination: CustomARViewRepresentable()) {
                              Image("LocationForest")
                                  .resizable()
                                  .scaledToFit()
                                  .padding()
                              }
                          .frame(width: 105, height: 150)
                          .position(x:330.0, y:670.0)
                          }
                  }
                  .background {
                      Image("ImageBackground").ignoresSafeArea()
                  }
            }
        }
    }
}

#Preview {
    Page1AR()
}

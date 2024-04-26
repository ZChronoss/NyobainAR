//
//  ContentView.swift
//  Nyoba_ARKit
//
//  Created by Renaldi Antonio on 22/04/24.
//

import SwiftUI

struct ContentView: View {
    @State private var models = [
        "IniDioramaJadi",
        "ToyBiplane",
        "Tiger"
    ]
    
    var body: some View {
        CustomARViewRepresentable()
            .ignoresSafeArea()
            .overlay(alignment: .bottom){
                ScrollView(.horizontal){
                    HStack{
                        Button{
                            ARManager.shared.actionStream.send(.removeAllAnchors)
                        }label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.red)
                                .clipShape(.rect(cornerRadius: 16))
                                .tint(.black)
                        }
                        
                        ForEach(models, id: \.self){ model in
                            Button{
                                ARManager.shared.actionStream.send(.placeBlock(model: model))
                            }label: {
                                Image(model)
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .background(.regularMaterial)
                                    .clipShape(.rect(cornerRadius: 16))
                            }
                        }
                        
                        Button{
                            ARManager.shared.actionStream.send(.addBackgroundImage)
                        }label: {
                            Image("Mountain_BG")
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.regularMaterial)
                                .clipShape(.rect(cornerRadius: 16))
                        }
                    }
                    .padding()
                }
            }
    }
}

#Preview {
    ContentView()
}

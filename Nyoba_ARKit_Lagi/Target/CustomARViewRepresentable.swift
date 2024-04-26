//
//  CustomARViewRepresentable.swift
//  Nyoba_ARKit
//
//  Created by Renaldi Antonio on 22/04/24.
//

import SwiftUI

struct CustomARViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> some UIView {
        return CustomARView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

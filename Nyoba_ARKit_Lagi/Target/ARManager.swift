//
//  ARManager.swift
//  Nyoba_ARKit
//
//  Created by Renaldi Antonio on 23/04/24.
//

// combine allows us to send data from one part of the app to another part of the app
// @Published is combine
import Combine

// this class is singleton
// purpose of this is to forward all this action to CustomARView
class ARManager{
    static let shared = ARManager()
    
    private init(){
        
    }
    
    var actionStream = PassthroughSubject<ARAction, Never>()
}

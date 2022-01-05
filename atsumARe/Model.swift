//
//  Model.swift
//  atsumARe
//
//  Created by 王凱 on 2022/01/05.
//

import UIKit
import SwiftUI
import RealityKit
import Combine

class Model: Identifiable {
    let id : UUID
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    var confidence: Double
    var enabled: Bool
    var buttonBackgroundColor: Color
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        id = UUID()
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        
        if self.modelName == "toy_biplane" || self.modelName == "toy_robot_vintage" {
            self.confidence = 1.0
        } else {
            self.confidence = 0.0
        }
        
        if self.confidence > 0.5 {
            self.enabled = true
            self.buttonBackgroundColor = Color.white
        } else {
            self.enabled = false
            self.buttonBackgroundColor = Color.gray
        }
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: {loadCompletion in
                // Handle error
                print("[DEBUG] Unable to load modelEntity for modelName: \(self.modelName)")
            }, receiveValue: {modelEntity in
                // Get model entity
                self.modelEntity = modelEntity
                print("[DEBUG] Successfully loaded modelEntity for modelName: \(self.modelName)")
            })
    }
}

extension Model {
    func updateConfidence(confidence: Double) {
        self.confidence = confidence
        if self.confidence > 0.2 {
            self.enabled = true
            self.buttonBackgroundColor = Color.white
        } else {
            self.enabled = false
            self.buttonBackgroundColor = Color.gray
        }
    }
}

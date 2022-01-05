//
//  HeaderView.swift
//  atsumARe
//
//  Created by 王凱 on 2022/01/05.
//

import SwiftUI

struct UserView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    @Binding var isDetectionEnabled: Bool
    @Binding var models: [Model]
    
    var body: some View {
        VStack {
            // Header view
            HStack(alignment: .top) {
                // Model Confidence View
                VStack(alignment: .leading) {
                    ForEach(self.models.sorted(by: {(lhs, rhs) -> Bool in
                        lhs.confidence > rhs.confidence})[..<7]) {model in
                            ConfidenceCardView(name: model.modelName, confidence: model.confidence)
                    }
                }
                .frame(width: 120)
                Spacer()
                // Detect Button View
                Button(action: {
                    self.isDetectionEnabled = false
                }) {
                    Image(systemName: self.isDetectionEnabled ? "magnifyingglass" : "hourglass")
                        .frame(width: 60, height: 60)
                        .font(.title)
                        .foregroundColor(Color.gray)
                        .background(Color.white.opacity(0.75))
                        .cornerRadius(30)
                        .padding(20)
                }
            }
            .padding(10)
            
            Spacer()
            
            // Footer View
            // Placement Buttons View
            if self.isPlacementEnabled {
                HStack {
                    // Cancel Button
                    Button(action: {
                        print("[DEBUG]: model placement canceled")
                        self.resetPlacementParameters()
                    }){
                        Image(systemName: "xmark")
                            .frame(width: 60, height: 60)
                            .font(.title)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(30)
                            .padding(20)
                    }
                    // Confirm Button
                    Button(action: {
                        print("[DEBUG]: model placement confirmed")
                        self.modelConfirmedForPlacement = self.selectedModel
                        self.resetPlacementParameters()
                    }){
                        Image(systemName: "checkmark")
                            .frame(width: 60, height: 60)
                            .font(.title)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(30)
                            .padding(20)
                    }
                }
            } else {
                // Model Picker View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        ForEach(self.models.sorted(by: {(lhs, rhs) -> Bool in
                            lhs.confidence > rhs.confidence})) {model in
                            Button(action: {
                                if model.enabled {
                                    print("[DEBUG]: selected model with name: \(model.modelName) - \(model.confidence)")
                                    self.isPlacementEnabled = true
                                    self.selectedModel = model
                                } else {
                                    print("[DEBUG]: selected disabled model: \(model.modelName) - \(model.confidence)")
                                }
                            }){
                                Image(uiImage: model.image)
                                    .resizable()
                                    .frame(height: 60)
                                    .aspectRatio(1/1, contentMode: .fit)
                                    .padding(10)
                                    .background(model.buttonBackgroundColor)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(20)
                .background(Color.black.opacity(0.5))
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

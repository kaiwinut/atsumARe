//
//  ModelPickerView.swift
//  atsumARe
//
//  Created by 王凱 on 2022/01/05.
//

import SwiftUI

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    @Binding var models: [Model]
    
    var body: some View {
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

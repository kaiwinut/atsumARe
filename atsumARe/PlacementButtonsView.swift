//
//  PlacementButtonsView.swift
//  atsumARe
//
//  Created by 王凱 on 2022/01/05.
//

import SwiftUI

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?

    var body: some View {
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
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
        
    }
}

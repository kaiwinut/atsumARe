//
//  ConfidenceCardView.swift
//  atsumARe
//
//  Created by 王凱 on 2022/01/05.
//

import SwiftUI

struct ConfidenceCardView: View {
    var name: String
    var confidence: Double
    
    var body: some View {
        if !(name == "toy_biplane" || name == "toy_robot_vintage") {
            VStack {
                HStack {
                    Text("\(name)")
                    Spacer()
                    Text("\(Int(confidence * 100))%")
                }
                ProgressView(value: confidence)
            }
        }
    }
}

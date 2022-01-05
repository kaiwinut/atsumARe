//
//  ModelConfidenceView.swift
//  atsumARe
//
//  Created by 王凱 on 2022/01/05.
//

import SwiftUI

struct ModelConfidenceView: View {
    @Binding var models: [Model]
    
    var body: some View {
        ForEach(self.models.sorted(by: {(lhs, rhs) -> Bool in
            lhs.confidence > rhs.confidence})) {model in
                Text("\(model.modelName) - \(model.confidence)")
        }
    }
}

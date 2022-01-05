//
//  ContentView.swift
//  atsumARe_swiftui
//
//  Created by 王凱 on 2022/01/04.
//

import UIKit
import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?

    @State private var models: [Model] = {
       //Dynamically get filename
        let filemanager = FileManager.default
        guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else { return [] }
        var availableModels: [Model] = []
        for filename in files where filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        return availableModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewControllerContainer(modelConfirmedForPlacement: $modelConfirmedForPlacement, models: $models)
                .edgesIgnoringSafeArea(.all)
            VStack {
                ModelConfidenceView(models: $models)
                Spacer()
                if self.isPlacementEnabled {
                    PlacementButtonsView(isPlacementEnabled: $isPlacementEnabled, selectedModel: $selectedModel, modelConfirmedForPlacement: $modelConfirmedForPlacement)
                } else {
                    ModelPickerView(isPlacementEnabled: $isPlacementEnabled, selectedModel: $selectedModel, models: $models)
                }
            }
        }
    }
}

struct ARViewControllerContainer: UIViewControllerRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    @Binding var models: [Model]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ARViewControllerContainer>) -> ARViewController {
        let viewController = ARViewController(modelConfirmedForPlacement: $modelConfirmedForPlacement, models: $models)
        return viewController
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: UIViewControllerRepresentableContext<ARViewControllerContainer>) {
        if let model = modelConfirmedForPlacement{
            uiViewController.handleConfirmButtonTap(model: model)
        }
    }

    func makeCoordinator() -> ARViewControllerContainer.Coordinator {
        return Coordinator()
    }

    class Coordinator {
        
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

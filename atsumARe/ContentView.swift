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
    @State private var isDetectionEnabled: Bool = true
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
            ARViewControllerContainer(modelConfirmedForPlacement: $modelConfirmedForPlacement, models: $models, isDetectionEnabled: $isDetectionEnabled)
                .edgesIgnoringSafeArea(.all)
            UserView(isPlacementEnabled: $isPlacementEnabled, selectedModel: $selectedModel, modelConfirmedForPlacement: $modelConfirmedForPlacement, isDetectionEnabled: $isDetectionEnabled, models: $models)
        }
    }
}

struct ARViewControllerContainer: UIViewControllerRepresentable {
    let modelConfirmedForPlacement: Binding<Model?>
    let models: Binding<[Model]>
    let isDetectionEnabled: Binding<Bool>
    
    class Coordinator: ARViewControllerDelegate {
        let modelConfirmedForPlacementBinding: Binding<Model?>
        let modelsBinding: Binding<[Model]>
        let isDetectionEnabledBinding: Binding<Bool>

        init(modelConfirmedForPlacementBinding: Binding<Model?>, modelsBinding: Binding<[Model]>, isDetectionEnabledBinding: Binding<Bool>) {
            self.modelConfirmedForPlacementBinding = modelConfirmedForPlacementBinding
            self.modelsBinding = modelsBinding
            self.isDetectionEnabledBinding = isDetectionEnabledBinding
        }
        
        func classificationOccured(_ viewController: ARViewController, modelConfirmedForPlacement: Model?, models: [Model], isDetectionEnabled: Bool){
            modelConfirmedForPlacementBinding.wrappedValue = modelConfirmedForPlacement
            modelsBinding.wrappedValue = models
            isDetectionEnabledBinding.wrappedValue = isDetectionEnabled
        }
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ARViewControllerContainer>) -> ARViewController {
        let viewController = ARViewController(modelConfirmedForPlacement: modelConfirmedForPlacement, models: models, isDetectionEnabled: isDetectionEnabled)
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: UIViewControllerRepresentableContext<ARViewControllerContainer>) {
        if let model = modelConfirmedForPlacement.wrappedValue{
            uiViewController.handleConfirmButtonTap(model: model)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(modelConfirmedForPlacementBinding: modelConfirmedForPlacement, modelsBinding: models, isDetectionEnabledBinding: isDetectionEnabled)
    }

    
}

protocol ARViewControllerDelegate: AnyObject {
    func classificationOccured(_ viewController: ARViewController, modelConfirmedForPlacement: Model?, models: [Model], isDetectionEnabled: Bool)
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

//
//  ViewController.swift
//  atsumARe
//
//  Created by 王凱 on 2022/01/04.
//

import UIKit
import SwiftUI
import RealityKit
import ARKit
import Vision
import MultipeerSession

class ARViewController: UIViewController {
    
    @Binding var modelConfirmedForPlacement: Model?
    @Binding var models: [Model]
    private var arView: ARView!
    
    var multipeerSession: MultipeerSession?
    var sessionIDObservation: NSKeyValueObservation?
    
    init(modelConfirmedForPlacement: Binding<Model?>, models: Binding<[Model]>) {
        self._modelConfirmedForPlacement = modelConfirmedForPlacement
        self._models = models
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupARView()
        setupMultipeerSession()
        
        arView.session.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        config.isCollaborationEnabled = true
        
        arView.session.run(config)
    }
    
    func setupMultipeerSession() {
        // Use key-value observation to monitor your ARSession's identifier.
        sessionIDObservation = arView.session.observe(\.identifier, options: [.new]) { object, change in
            print("SessionID changed to: \(change.newValue!)")
            // Tell all other peers about your ARSession's changed ID, so
            // that they can keep track of which ARAnchors are yours.
            guard let multipeerSession = self.multipeerSession else { return }
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        
        multipeerSession = MultipeerSession(serviceName: "multiuser-ar", receivedDataHandler: self.receivedData, peerJoinedHandler: self.peerJoined, peerLeftHandler: self.peerLeft, peerDiscoveredHandler: self.peerDiscovered)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let anchor = ARAnchor(name: "RedMark", transform: arView!.cameraTransform.matrix)
        arView.session.add(anchor: anchor)
    }
    
    func handleConfirmButtonTap(model: Model) {
        let anchor = ARAnchor(name: model.modelName, transform: arView!.cameraTransform.matrix)
        arView.session.add(anchor: anchor)
    }
    
    func placeRedMark(named entityName: String, for anchor: ARAnchor) {
        print("[DEBUG]: Connection is successful.")
        let mesh = MeshResource.generateSphere(radius: 0.005)
        let color = UIColor.red
        let material = SimpleMaterial(color: color, isMetallic: false)
        let colorSphere = ModelEntity(mesh: mesh, materials: [material])
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(colorSphere)
        arView.scene.addAnchor(anchorEntity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.arView.scene.removeAnchor(anchorEntity)
        }
    }
    
    func placeConfirmedObject(model: Model, for anchor: ARAnchor) {
        if let modelEntity = model.modelEntity {
            print("[DEBUG]: adding model to scene - \(model.modelName)")
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.move(to: Transform(pitch: .pi/2, yaw: 0, roll: 0), relativeTo: anchorEntity)
            anchorEntity.addChild(modelEntity.clone(recursive: true))
            arView.scene.addAnchor(anchorEntity)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        } else {
            print("[DEBUG]: unable to load model entity for \(model.modelName)")
        }
    }
    
    func classifyFrame(ciImage: CIImage) {
        let request = VNClassifyImageRequest()
        let requestHandler = VNImageRequestHandler(ciImage: ciImage,
                                                   orientation: .up,
                                                   options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("[DEBUG]: Can't make request due to \(error)")
            }
            
            DispatchQueue.main.async {
                guard let results = request.results else { return }
                var maxConfidence = 0.0
                
                for index in 0..<self.models.count {
                    maxConfidence = 0.0
                    if self.models[index].modelName != "toy_biplane" && self.models[index].modelName != "toy_robot_vintage" {
                        results.forEach {
                            if (Double($0.confidence) > 0.1 && Double($0.confidence) > maxConfidence && $0.identifier.contains(self.models[index].modelName)) {
                                maxConfidence = Double($0.confidence)
                            }
                        }
                        self.models[index].updateConfidence(confidence: maxConfidence)
                        print("[DEBUG] Updating confidence for \(self.models[index].modelName) - \(self.models[index].confidence)")
                    }
                }
            }
        }
    }
}

// MARK: - ARSessionDelegate

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "RedMark" {
                placeRedMark(named: anchorName, for: anchor)
            }
            
            else if let anchorName = anchor.name {
                for model in self.models {
                    if model.modelName == anchorName {
                        placeConfirmedObject(model: model, for: anchor)
                        break
                    }
                }
            }
            
            if let participantAnchor = anchor as? ARParticipantAnchor {
                print("[DEBUG]: Successfully conenected with another user.")
                // For some reason not working...
                let anchorEntity = AnchorEntity(anchor: participantAnchor)
                let mesh = MeshResource.generateSphere(radius: 0.01)
                let color = UIColor.red
                let material = SimpleMaterial(color: color, isMetallic: false)
                let colorSphere = ModelEntity(mesh: mesh, materials: [material])

                anchorEntity.addChild(colorSphere)
                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        classifyFrame(ciImage: CIImage(cvPixelBuffer: frame.capturedImage))
    }
}

// MARK: - MultipeerSession

extension ARViewController {
    private func sendARSessionIDTo(peers: [PeerID]) {
        guard let multipeerSession = multipeerSession else { return }
        let idString = arView.session.identifier.uuidString
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
    }

    func receivedData(_ data: Data, from peer: PeerID) {
        guard let multipeerSession = multipeerSession else { return }
        
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            arView.session.update(with: collaborationData)
            return
        }
        // ...
        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                     offsetBy: sessionIDCommandString.count)...])
            // If this peer was using a different session ID before, remove all its associated anchors.
            // This will remove the old participant anchor and its geometry from the scene.
            if let oldSessionID = multipeerSession.peerSessionIDs[peer] {
                removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
            }
            
            multipeerSession.peerSessionIDs[peer] = newSessionID
        }
    }
    
    func peerDiscovered(_ peer: PeerID) -> Bool {
        guard let multipeerSession = multipeerSession else { return false }
        
        if multipeerSession.connectedPeers.count > 4 {
            // Do not accept more than four users in the experience.
            print("A fifth peer wants to join the experience.\nThis app is limited to four users.")
            return false
        } else {
            return true
        }
    }
    /// - Tag: PeerJoined
    func peerJoined(_ peer: PeerID) {
        print("""
            A peer wants to join the experience.
            Hold the phones next to each other.
            """)
        // Provide your session ID to the new user so they can keep track of your anchors.
        sendARSessionIDTo(peers: [peer])
    }
        
    func peerLeft(_ peer: PeerID) {
        guard let multipeerSession = multipeerSession else { return }
        
        print("A peer has left the shared experience.")
        
        // Remove all ARAnchors associated with the peer that just left the experience.
        if let sessionID = multipeerSession.peerSessionIDs[peer] {
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            multipeerSession.peerSessionIDs.removeValue(forKey: peer)
        }
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
        guard let frame = arView.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == identifier {
                arView.session.remove(anchor: anchor)
            }
        }
    }
    
    /// - Tag: DidOutputCollaborationData
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        guard let multipeerSession = multipeerSession else { return }
        if !multipeerSession.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
            else { fatalError("Unexpectedly failed to encode collaboration data.") }
            // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
            let dataIsCritical = data.priority == .critical
            multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
        } else {
            print("Deferred sending collaboration to later because there are no peers.")
        }
    }
}

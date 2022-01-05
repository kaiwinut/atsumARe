//
//  AppDelegate.swift
//  atsumARe
//
//  Created by 王凱 on 2022/01/05.
//


import SwiftUI

@main
struct SwiftUIAppSample: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // 追加する
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}


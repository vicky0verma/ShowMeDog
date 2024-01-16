//
//  AppDelegate.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 15/01/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window:UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AssemblerInitialiser().getEntryPoint()
        return true
    }


}


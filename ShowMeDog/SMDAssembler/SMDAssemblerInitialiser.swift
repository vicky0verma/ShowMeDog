//
//  SMDAssemblerInitialiser.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 16/01/24.
//

import Foundation
import Swinject
import UIKit
import RxSwift

@objc class AssemblerInitialiser: NSObject {
    var assembler: Assembler
    var interModuleContainer: Container
    
    override init() {
        interModuleContainer = Container()
        self.assembler = Assembler([SMDAssembly()], container: interModuleContainer)
        
    }
    @objc func getEntryPoint() {
        let wf = interModuleContainer.resolve(ShowMeDogCoordinatorProtocol.self)
        guard let vc = wf?.getEntryPoint() else { return }
        let appDelegate = UIApplication.shared.delegate
        if let window = appDelegate?.window {
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        }
    }
}

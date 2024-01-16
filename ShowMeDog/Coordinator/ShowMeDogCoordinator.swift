//
//  ShowMeDogCoordinator.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 16/01/24.
//

import Foundation
import SwinjectStoryboard
import Swinject
import RxSwift
import RxRelay
import UIKit

//sourcery: AutoMockable
protocol ShowMeDogCoordinatorProtocol {
    func getEntryPoint() -> UIViewController
    func showBreedBtnPressed()
}

final class ShowMeDogCoordinator: ShowMeDogCoordinatorProtocol {
    private let showMeDogStoryBoard: SwinjectStoryboard!
    var primeOnboardingImageSet = [UIImage]()
    init(resolver: Resolver) {
        showMeDogStoryBoard  = SwinjectStoryboard.create(name: String(describing: "Main"), bundle: Bundle(for: ShowMeDogCoordinator.self), container: resolver)
    }
    
    func showBreedBtnPressed() {
        
    }
    
    func getEntryPoint() -> UIViewController {
        let vc = showMeDogStoryBoard.instantiateViewController(of: ShowMeDogViewController.self)
        return vc
    }
}

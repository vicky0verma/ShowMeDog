//
//  SMDAssembler.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 15/01/24.
//

import Foundation
import Swinject

final class SMDAssembly: Assembly {
    func assemble(container: Container) {
        assembleShowMeDog(container)
    }
}

func assembleShowMeDog(_ container: Container) {
    container.register(NetworkClientType.self) { _ in
        MobileAPIClient()
    }
    container.register(SMDNetworkProtocol.self) { r in
        return SMDNetwork(network: r.resolve(NetworkClientType.self)!)
    }
    
    container.register(SMDUseCaseProtocol.self) { r in
        let network = r.resolve(SMDNetworkProtocol.self)!
        let smdUseCase = SMDUseCase(smdnetwork: network)
        return smdUseCase
    }
    
    container.register(ShowMeDogCoordinatorProtocol.self) { r in
        let corporateActionCoordinator = ShowMeDogCoordinator(resolver: r)
        return corporateActionCoordinator
    }
    
    container.register(ShowMeDogViewModelProtocol.self) { resolver in
        let vm = ShowMeDogViewModel(usecase: resolver.resolve(SMDUseCaseProtocol.self)!, coordinator: resolver.resolve(ShowMeDogCoordinatorProtocol.self)!)
        return vm
    }
    
    container.storyboardInitCompleted(ShowMeDogViewController.self) { (resolver, controller: ShowMeDogViewController) in
        controller.viewModel = resolver.resolve(ShowMeDogViewModelProtocol.self)
    }
    
}

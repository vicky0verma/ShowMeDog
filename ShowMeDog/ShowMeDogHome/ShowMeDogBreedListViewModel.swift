//
//  ShowMeDogBreedListViewModel.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 17/01/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol ShowMeDogBreedListViewModelProtocol {
    func fetchBreedList()
}

class ShowMeDogBreedListViewModel:ShowMeDogBreedListViewModelProtocol {
    var usecase:SMDUseCaseProtocol
    var coordinator:ShowMeDogCoordinatorProtocol
    init(usecase: SMDUseCaseProtocol, coordinator: ShowMeDogCoordinatorProtocol) {
        self.usecase = usecase
        self.coordinator = coordinator
    }
    
    func fetchBreedList() {
        
    }
    
}

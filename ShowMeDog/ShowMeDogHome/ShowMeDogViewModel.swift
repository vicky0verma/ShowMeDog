//
//  ShowMeDogViewModel.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 16/01/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol ShowMeDogViewModelProtocol {
    var imageFetched:PublishSubject<String>?{get set}
    func getImageURL(next:Bool)
    var selectedBreed:String?{get set}
    var imgURL:String?{get set}
    var selectBreedPublisher:PublishSubject<String>?{get set}
}

class ShowMeDogViewModel:ShowMeDogViewModelProtocol {
    var usecase:SMDUseCaseProtocol
    var coordinator:ShowMeDogCoordinatorProtocol
    var imageFetched:PublishSubject<String>? = PublishSubject<String>()
    var bag = DisposeBag()
    var selectedBreed:String?
    var selectBreedPublisher:PublishSubject<String>? = PublishSubject<String>()
    var imgURL = ""
   public init(usecase: SMDUseCaseProtocol, coordinator: ShowMeDogCoordinatorProtocol) {
        self.usecase = usecase
        self.coordinator = coordinator
    }
    
    func fetchDogImage() {
        self.usecase.getDogImage(breedName: selectedBreed).observeOn(MainScheduler.instance).subscribe { [weak self] (event) in
            guard let self = self else { return }
            switch event {
            case .success(let response):
                self.imgURL = response.imgUrl ?? ""
                self.imageFetched?.onNext(response.imgUrl ?? "")
            case .error(_):
                print("error")
            }
        } >>> bag
    }
    
    func getImageURL(next:Bool) {
        if let favImage = UserDefaults.standard.value(forKey: DefaultsConstants.kFavImage) as? String, !next {
            self.imgURL = favImage
            self.imageFetched?.onNext(favImage)
        }
        else if let favBreed = UserDefaults.standard.value(forKey: DefaultsConstants.kFavBreed) as? String {
            self.selectBreedPublisher?.onNext(favBreed)
            self.selectedBreed = favBreed
            self.fetchDogImage()
        }
        else {
            self.fetchDogImage()
        }
    }
        
}

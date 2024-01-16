//
//  ShowMeDogViewController.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 16/01/24.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
class ShowMeDogViewController: UIViewController {
    var viewModel:ShowMeDogViewModelProtocol!
    @IBOutlet weak var dogImage: UIImageView!
    @IBOutlet weak var favImgBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var selectBreedBtn: UIButton!
    @IBOutlet weak var favBreedBtn: UIButton!
    var bag = DisposeBag()
    var currentImgURL = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
        self.viewModel.getImageURL(next: false)
    }

    private func setupBindings() {
        self.viewModel.imageFetched?.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] imageURL in
            self?.dogImage.sd_setImage(with: URL.init(string: imageURL), placeholderImage: UIImage.init(systemName: "photo.artframe"))
            self?.currentImgURL = imageURL
        }) >>> bag
        
        
        self.viewModel.selectBreedPublisher?.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] selectedBreedName in
            self?.viewModel.selectedBreed = selectedBreedName
            self?.selectBreedBtn.setTitle(selectedBreedName, for: .normal)
        }) >>> bag
        
        self.nextBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.favImgBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            self.viewModel.getImageURL(next: true)
        }) >>> bag
        
        self.favImgBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
             var currentFavImage = ""
            if let currentDefault = UserDefaults.standard.value(forKey: DefaultsConstants.kFavImage) as? String {
                currentFavImage = currentDefault
            }
            if currentImgURL != "" {
                if currentImgURL == currentFavImage {
                    UserDefaults.standard.removeObject(forKey: DefaultsConstants.kFavImage)
                    self.favImgBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                } else {
                    UserDefaults.standard.setValue(currentImgURL, forKey: DefaultsConstants.kFavImage)
                    self.favImgBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
            }
        }) >>> bag
        
        self.favBreedBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
             var currentFavBreed = ""
            if let currentDefault = UserDefaults.standard.value(forKey: DefaultsConstants.kFavBreed) as? String {
                currentFavBreed = currentDefault
            }
            if let breedName = self.viewModel.selectedBreed {
                if breedName == currentFavBreed {
                    UserDefaults.standard.removeObject(forKey: DefaultsConstants.kFavBreed)
                    self.favBreedBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                } else {
                    UserDefaults.standard.setValue(breedName, forKey: DefaultsConstants.kFavBreed)
                    self.favBreedBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
            }
        }) >>> bag
        
        self.selectBreedBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
           //showBreed list screen
        }) >>> bag
    }
}

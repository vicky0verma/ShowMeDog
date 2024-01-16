//
//  ShowMeDogTests.swift
//  ShowMeDogTests
//
//  Created by Vikas Soni on 17/01/24.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import ObjectMapper

final class ShowMeDogTests: XCTestCase {
    var vm:ShowMeDogViewModel!
    var coordinator:ShowMeDogCoordinatorProtocolMock!
    var usecase:SMDUseCaseProtocolMock!
    var bag: DisposeBag!
    override func setUp() {
        self.coordinator = ShowMeDogCoordinatorProtocolMock()
        self.usecase = SMDUseCaseProtocolMock()
        self.vm = ShowMeDogViewModel(usecase: self.usecase, coordinator: self.coordinator)
        bag = DisposeBag()
    }
    
    func testFavImageString() {
        UserDefaults.standard.setValue(APIURL.randomImage.rawValue, forKey: DefaultsConstants.kFavImage)
        self.vm.getImageURL(next: false)
        XCTAssertTrue(self.vm.imgURL == APIURL.randomImage.rawValue)
    }
    
    func testFavBreedString() {
        UserDefaults.standard.removeObject(forKey: DefaultsConstants.kFavImage)
        UserDefaults.standard.setValue("labrador", forKey: DefaultsConstants.kFavBreed)
        self.vm.getImageURL(next: false)
        XCTAssertTrue(self.vm.selectedBreed == "labrador")
    }
    
    func testApiResponseCase() {
        UserDefaults.standard.removeObject(forKey: DefaultsConstants.kFavImage)
        UserDefaults.standard.removeObject(forKey: DefaultsConstants.kFavImage)
        usecase.given(.getDogImage(breedName: .any, willReturn: Single.just(self.getImageData())))
        
        let _expectation = expectation(description: "For No data/Empty Response")
        vm.imageFetched?.subscribe(onNext: { [weak self] shouldStopLoader in
            _expectation.fulfill()
            XCTAssertTrue(self?.vm.imgURL != "")
        }).disposed(by: bag)
        vm.getImageURL(next: true)
        waitForExpectations(timeout: 2) { (error) in
            guard let error = error else { return }
            XCTFail("\(error)")
        }
    }
    
    
    func getImageData() -> RandomImageResponse {
        var response: RandomImageResponse!
        do {
            response = try RandomImageResponse.init(map: Map.init(mappingType: .fromJSON, JSON: [
                "message":["https://images.dog.ceo/breeds/spaniel-cocker/n02102318_12613.jpg"],"status":["success"]]))
            return response
        } catch { }
        return response
    }
    
}

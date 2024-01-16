//
//  SMDUseCase.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 15/01/24.
//

import Foundation
import RxSwift
import RxCocoa

//sourcery: AutoMockable
protocol SMDUseCaseProtocol {
    func getDogImage(breedName:String?) -> Single<RandomImageResponse>
}

final class SMDUseCase: SMDUseCaseProtocol {
    var SMDnetwork: SMDNetworkProtocol
    
    init(smdnetwork: SMDNetworkProtocol) {
        self.SMDnetwork = smdnetwork
    }
    func getDogImage(breedName:String?) -> Single<RandomImageResponse> {
        return SMDnetwork.getDogImage(breedName: breedName)
    }
}

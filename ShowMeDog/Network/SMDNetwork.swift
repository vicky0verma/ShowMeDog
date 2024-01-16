//
//  SMDNetwork.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 15/01/24.
//

import Foundation
import RxSwift
import RxCocoa

//sourcery: AutoMockable
protocol SMDNetworkProtocol {
    func getDogImage(breedName:String?) -> Single<RandomImageResponse>
}


final class SMDNetwork: SMDNetworkProtocol {
    
    private let network: NetworkClientType
    
    init(network: NetworkClientType) {
        self.network = network
    }
    
    func getDogImage(breedName:String?) -> Single<RandomImageResponse> {
        var url = APIURL.randomImage.rawValue
        if let breedName = breedName {
            url = url.replacingOccurrences(of: "breeds", with: breedName)
        }
        var r = Request(method: .get, path: APIURL.randomImage.rawValue, cachingOption: .none)
        r.urlType = APIURL.randomImage
        return network.request(r)
    }
    
}

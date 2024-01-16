//
//  SMDResponseEntity.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 15/01/24.
//

import Foundation
import ObjectMapper

public struct RandomImageResponse:ImmutableMappable {
    var imgUrl:String?
    var status:String?
}

extension RandomImageResponse {
    public init(map: Map) throws {
        self.imgUrl = try? map.value("message")
        self.status = try? map.value("status")
    }
}

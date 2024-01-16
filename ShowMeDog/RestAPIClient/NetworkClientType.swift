//
//  NetworkClientType.swift
//
//
//  Created by Vikas Soni on 15/01/24.
//  Copyright © 2017 NedBank. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

enum DataError: Error {
    case failedToMapObject
    case invalidURL
    case emptyResponse
    case noContent
    case nonZeroResponse(code: Int, desc: String?, title: String? )
    case badResponse(code: Int?, desc: String?)
    case timeout
    case upgradePlanError(code: String, desc: String?, title: String?, ctaText: String?, image: UIImage?)
}

extension DataError {
    var code: Int {
        switch self {
        case .nonZeroResponse(let code, _, _):
            return code
        case .badResponse(let code, _):
            return code ?? 0
        case .emptyResponse:
            return 1000
        default:
            return 0
        }
    }
    var description: String? {
        switch self {
        case .nonZeroResponse(_, let description, _):
            return description ?? "Some Error Occured"
        case .badResponse(_, let description):
            return description ?? "Some Error Occured"
        case .upgradePlanError(_, let description, _, _, _):
            return description ?? "Some Error Occured"
        default:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .badResponse:
            return "bad response"
        case .nonZeroResponse(_, _, let title):
            return title ?? "Some Error Occured"
        case .upgradePlanError(_, _, let title, _, _):
            return title ?? "Some Error Occured"
        default:
            return nil
        }
    }
    var errorCode: String? {
        switch self {
        case .upgradePlanError(let code, _, _, _, _):
            return code
        default:
            return nil
        }
    }
    var ctaText: String? {
        switch self {
        case .upgradePlanError(_, _, _, let ctaText, _):
            return ctaText
        default:
            return nil
        }
    }
    var image: UIImage? {
        switch self {
        case .upgradePlanError(_, _, _, _, let image):
            return image
        default:
            return nil
        }
    }
}

extension DataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .nonZeroResponse(_, let description, _):
            return description ?? "Some Error Occured"
        case .badResponse(_, let description):
            return description ?? "Some Error Occured"
        default:
            return nil
        }
    }
}

protocol NetworkClientType {
    var baseURL: URL? { get }
    var livelinessURL: URL? {get}
    func request<Response: ImmutableMappable>(_ request: Request) -> Single<Response>
    func request<Response: ImmutableMappable>(_ request: Request) -> Single<[Response]>
    func rawRequest(_ request: Request) -> Single<Any>
}

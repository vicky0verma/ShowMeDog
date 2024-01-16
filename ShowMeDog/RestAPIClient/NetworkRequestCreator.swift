//
//  NetworkRequestCreator.swift
//
//  Created by Vikas Soni on 15/01/24.
//

import Foundation
import RxSwift
import Alamofire
import ObjectMapper

struct Request: SMDCachable {
    let method: Alamofire.HTTPMethod
    let path: String
    var parameters: [String: Any]
    var headerParam: [[String: Any]] = []
    let parametersArray: [Any]?
    var urlType: APIURL = .base
    var upd: String?
    var isForDownloadFeature: Bool = false
    var cachingOption: SMDCachingOption
    init(method: Alamofire.HTTPMethod, path: String, cachingOption: SMDCachingOption, headerParam: [[String: Any]] = [], shouldAddssoId: Bool = false ) {
        self.method = method
        self.path = path
        self.parameters = [:]
        self.parametersArray = nil
        self.cachingOption = cachingOption
        self.headerParam = headerParam
    }

    init(method: Alamofire.HTTPMethod, path: String, parameters: [String: Any], cachingOption: SMDCachingOption, headerParam: [[String: Any]] = []) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.parametersArray = nil
        self.cachingOption = cachingOption
        self.headerParam = headerParam
    }

    init(method: Alamofire.HTTPMethod, path: String, parametersArray: [Any], cachingOption: SMDCachingOption, headerParam: [[String: Any]] = [], shouldAddssoId: Bool = false) {
        self.method = method
        self.path = path
        self.parameters = [:]
        self.parametersArray = parametersArray
        self.cachingOption = cachingOption
        self.headerParam = headerParam
    }
    init(method: Alamofire.HTTPMethod, path: String, parameters: [String: Any], ifForDownloadStatement: Bool, cachingOption: SMDCachingOption, headerParam: [[String: Any]] = [], shouldAddssoId: Bool = false) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.parametersArray = nil
        self.isForDownloadFeature = ifForDownloadStatement
        self.cachingOption = cachingOption
        self.headerParam = headerParam
    }
}

final class RequestBuilder {
    
    func buildRequest(baseURL: URL?, request: Request, mobileApiBaseURL: URL? = nil, statementPDFBaseUrl: URL? = nil) throws -> URLRequest {
            guard let baseURL = baseURL else { throw DataError.invalidURL }
            return try buildRequestFor(baseURL: baseURL, request: request)
    }
        
    private func buildRequestFor(baseURL: URL, request: Request) throws -> URLRequest {
        switch request.method {
        case .get: return try buildGet(baseURL, request)
        case .delete: return try buildDelete(baseURL, request)
        case .post: return try buildPost(baseURL, request)
        case .put: return try buildPut(baseURL, request)
        default: return try builBaseRequest(baseURL, request)
        }
    }

    private func buildGet(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var urlRequest = try builBaseRequest(baseURL, request)
        urlRequest = try URLEncoding().encode(urlRequest, with: request.parameters)
        return urlRequest
    }

    private func buildDelete(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var urlRequest = try builBaseRequest(baseURL, request)
        urlRequest = try URLEncoding().encode(urlRequest, with: request.parameters)
        return urlRequest
    }

    private func buildPost(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var urlRequest = try builBaseRequest(baseURL, request)
        if let parametersArray = request.parametersArray {
            urlRequest = try ArrayEncoding(parametersArray: parametersArray).encode(urlRequest, with: nil)
        } else {
            urlRequest = try JSONEncoding().encode(urlRequest, with: request.parameters)
        }
        return urlRequest
    }

    private func buildPut(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var urlRequest = try builBaseRequest(baseURL, request)
        if let parametersArray = request.parametersArray {
            urlRequest = try ArrayEncoding(parametersArray: parametersArray).encode(urlRequest, with: nil)
        } else {
            urlRequest = try JSONEncoding().encode(urlRequest, with: request.parameters)
        }
        return urlRequest
    }

    private func builBaseRequest(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var path = request.path
        if path.isEmpty {
            path = "\(baseURL.absoluteString)"
        } else if request.path.contains("https") {
            path = request.path
        } else {
            switch (request.path.hasPrefix("/"), baseURL.absoluteString.hasSuffix("/")) {
            case (false, false): path = "\(baseURL.absoluteString)/\(path)"
            case (true, true): path = "\(baseURL.absoluteString)/\(path)".replacingOccurrences(of: "///", with: "/")
            default: path = "\(baseURL.absoluteString)\(path)"
            }
        }

        path = path.replacingOccurrences(of: " ", with: "%20")
        
        guard let concatenatedURL = URL(string: path) else {
            throw DataError.invalidURL
        }

        guard var urlRequest = try? URLRequest(url: concatenatedURL, method: request.method) else {
            throw DataError.invalidURL
        }

        if let cachePolicy = request.cachePolicy {
            urlRequest.cachePolicy = cachePolicy
        } else {
            urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        }
     
        
        request.headerParam.forEach { dictItem in
            for (key, value) in dictItem {
                if let value = value as? String {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
        }
        
        return urlRequest
    }
}

struct ArrayEncoding: ParameterEncoding {

    let parametersArray: [Any]

    init(parametersArray: [Any]) {
        self.parametersArray = parametersArray
    }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        do {
            let data = try JSONSerialization.data(withJSONObject: parametersArray)

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            

            urlRequest.httpBody = data

        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}

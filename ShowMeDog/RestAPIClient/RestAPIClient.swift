//
//  RestAPIClient.swift
//
//  Created by Vikas Soni on 15/01/24.
//

import Foundation
import Alamofire
import RxSwift
import ObjectMapper

final class MobileAPIClient: NetworkClientType {
    var livelinessURL: URL?
    var baseURL: URL?
    private let dispatch: DispatchQueue
    private let requestBuilder = RequestBuilder()
    private let sessionManager: Session
    
    let bag = DisposeBag()
    
    init() {
        self.dispatch = DispatchQueue(label: "mobileNetworking", qos: .background, attributes: .concurrent)
        self.sessionManager = Session()
    }
    
    func request<Response: ImmutableMappable>(_ request: Request) -> Single<Response> {
        let urlRequest: URLRequest
        do {
            urlRequest = try requestBuilder.buildRequest(baseURL: URL.init(string:APIURL.randomImage.rawValue), request: request)
        } catch {
            return Single.error(error)
        }
        
        return Single<Response>.create { [unowned self] single in
            let request = self.sessionManager.request(urlRequest)
                .validateSessionExpiredStatus()
                .validate(statusCode: 200..<300)
                .validate(contentType: ["text/html", "application/json"])
                .responseJSON(queue: self.dispatch) { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let result = try Mapper<Response>().map(JSONObject: data)
                            single(.success(result))
                        } catch {
                            single(.error(DataError.failedToMapObject))
                        }
                    case .failure(let error):
                        single(.error(error))
                        return
                    }
                }
            
            return Disposables.create { request.cancel() }
        }
    }
    
    func request<Response: ImmutableMappable>(_ request: Request) -> Single<[Response]> {
        let urlRequest: URLRequest
        do {
            urlRequest = try requestBuilder.buildRequest(baseURL: baseURL, request: request)
        } catch {
            return Single.error(error)
        }
        
        return Single<[Response]>.create { single in
            let request = self.sessionManager.request(urlRequest)
                .validateSessionExpiredStatus()
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON(queue: self.dispatch) { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let result = try Mapper<Response>().mapArray(JSONObject: data)
                            single(.success(result))
                        } catch {
                            single(.error(DataError.failedToMapObject))
                        }
                    case .failure(let error):
                        single(.error(error))
                        return
                    }
                }
            return Disposables.create { request.cancel() }
        }
    }
    
    func rawRequest(_ request: Request) -> Single<Any> {
        let urlRequest: URLRequest
        do {
            urlRequest = try requestBuilder.buildRequest(baseURL: self.baseURL, request: request)
        } catch {
            return Single.error(error)
        }
        return Single<Any>.create { [unowned self] single in
            let request = self.sessionManager.request(urlRequest)
                .validateSessionExpiredStatus()
                .validate(statusCode: 200..<300)
                .responseString(queue: self.dispatch) { response in
                    switch response.result {
                        case .success(let value):
                            single(.success(value))
                        case .failure(let error):
                            single(.error(error))
                            return
                    }
                }
            return Disposables.create { request.cancel() }
        }
    }
}

//
//  DataRequest+ValidateExpiredSession.swift
//
//  Created by Vikas Soni on 15/01/24.
//

import Alamofire

extension Notification.Name {
    struct Session {
        /// Posted when a Session expires
        static let DidExpire = Notification.Name(rawValue: "SessionDidExpire")
    }
}

extension DataRequest {
    func validateSessionExpiredStatus() -> DataRequest {
        responseJSON { response in
            if let statusCode = response.response?.statusCode {
                if statusCode == 403 {
                    NotificationCenter.default.post(name: Notification.Name.Session.DidExpire, object: nil)
                }
            }
        }
        return self
    }
}

//
//  SWInjectUtils.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 16/01/24.
//

import UIKit
import SwinjectStoryboard

public extension SwinjectStoryboard {
    func instantiateViewController<T: UIViewController>(of: T.Type) -> T {
        let defaultIdentifier = ("\(T.self)".split(whereSeparator: { $0 == "." }).map(String.init).last) ?? ""

        guard let controller = instantiateViewController(withIdentifier: defaultIdentifier) as? T else {
            fatalError("Could not instantiate: storyboard \(self), identifier: \(defaultIdentifier)")
        }

        return controller
    }
}

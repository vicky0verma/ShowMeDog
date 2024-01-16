//
//  RXUtils.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 16/01/24.
//

import Foundation
import RxSwift
import RxCocoa

infix operator >>>: AdditionPrecedence
public func >>> (lhs: Disposable?, rhs: DisposeBag) {
    lhs?.disposed(by: rhs)
}

infix operator <->: AdditionPrecedence
infix operator <=>: AdditionPrecedence
public func <-> <T> (property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable().debug("Variable values in bind")
        .bind(to: property)

    let bindToVariable = property
        .debug("Property values in bind")
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted: {
            bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToVariable)
}

public func <=> <T> (property: ControlProperty<T>, behaviourRelay: BehaviorRelay<T>) -> Disposable {
    let bindToUIDisposable = behaviourRelay.asObservable().debug("Variable values in bind")
        .bind(to: property)
    
    let bindToVariable = property
        .debug("Property values in bind")
        .subscribe(onNext: { n in
            behaviourRelay.accept(n)
        }, onCompleted: {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create(bindToUIDisposable, bindToVariable)
}

public protocol Optionable {
    associatedtype WrappedType
    func unwrap() -> WrappedType
    func isEmpty() -> Bool
}

extension Optional: Optionable {
    public typealias WrappedType = Wrapped
    public func unwrap() -> WrappedType {
        return self!
    }
    public func isEmpty() -> Bool {
        return self == nil
    }
}

extension ObservableType where Element: Optionable {
    public func unwrap() -> Observable<Element.WrappedType> {
        return self.filter({ !$0.isEmpty() }).map({ $0.unwrap() })
    }
}

extension SharedSequence where SharingStrategy == DriverSharingStrategy, Element: Optionable {
    public func unwrap() -> SharedSequence<SharingStrategy, Element.WrappedType> {
        return self.filter({ !$0.isEmpty() }).map({ $0.unwrap() })
    }

    public func onNil() -> SharedSequence<SharingStrategy, Void> {
        return self.filter({ $0.isEmpty() }).map({ _ -> Void in
            /// Converts SharedSequence<DriverSharingStrategy, Element> to SharedSequence<DriverSharingStrategy, Void>
        })
    }
}

extension ObservableType where Element: Collection {
    public func toSequence() -> Observable<Element.Iterator.Element> {
        return self.flatMap({ array -> Observable<Element.Iterator.Element> in
            return Observable.create({ observer -> Disposable in
                for element in array {
                    observer.onNext(element)
                }
                observer.onCompleted()
                return Disposables.create()
            })
        })
    }
}

extension ObservableType {
    public func pausable<P: ObservableType> (_ pauser: P) -> Observable<Element> where P.Element == Bool {
        return withLatestFrom(pauser) { element, paused in
            (element, paused)
            }.filter { _, paused in
                paused
            }.map { element, _ in
                element
        }
    }
}

extension ObservableType {

    public func asVoid() -> Observable<Void> {
        return self.map { _ in
           /// Converts Element to  Void
        }
    }
}


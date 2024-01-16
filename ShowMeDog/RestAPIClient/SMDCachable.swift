//
//  SMDCachable.swift
//  ShowMeDog
//
//  Created by Vikas Soni on 15/01/24.
//
import Foundation

//MARK: SMDCachingOption
public enum SMDCachingOption {
    case none
    case inMemory
    case inMemoryAndDisk
}

public extension SMDCachingOption{
    var cachePolicy: URLRequest.CachePolicy?{
        switch self {
        case .none:
            return nil
        case .inMemory:
            return URLRequest.CachePolicy.returnCacheDataElseLoad
        case .inMemoryAndDisk:
            return URLRequest.CachePolicy.returnCacheDataElseLoad
        }
    }
}

//MARK: SMDCacheProtocol
public protocol SMDCachable{
    var cachingOption: SMDCachingOption { get }
}

public extension SMDCachable{
    var cachingOption: SMDCachingOption{
        return .none
    }
    
    var cachePolicy: URLRequest.CachePolicy?{
        return self.cachingOption.cachePolicy
    }
}


//MARK: SMDCacheManager
class CacheManager{
    private static let memoryCapacity = 10 * 1024 * 1024 //In-Memory Cache size 10 MB
    private static let diskCapacity = 10 * 1024 * 1024 //In-Memory Cache size 10 MB
    private init(){}
    
    static let inMemoryUrlCache: Foundation.URLCache = {
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: 0, diskPath: nil)
        return cache
    }()
    
    static let inMemoryAndDiskUrlCache: Foundation.URLCache = {
        let cache = URLCache.shared
        cache.memoryCapacity = memoryCapacity
        cache.diskCapacity = diskCapacity
        
        return cache
    }()
}

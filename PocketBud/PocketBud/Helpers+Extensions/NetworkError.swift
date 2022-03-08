//
//  NetworkError.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/8/22.
//

import Foundation

enum NetworkError: LocalizedError {
    

case ckError(Error)
case noData
case unableToDecode
case foundNil
case unableToSave

var errorDescription: String? {
    switch self {
    case .ckError(let error):
        return "Error: \(error.localizedDescription) -- \(error)"
    case .noData:
        return "The server responded with no data."
    case .unableToDecode:
        return "Unable to decode the data."
    case .foundNil:
        return "Nil was the value of fetched data"
    case .unableToSave:
        return "Unable to save to the cloud"
    }
}
}

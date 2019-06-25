//
//  File.swift
//  
//
//  Created by Finn Gaida on 25.06.19.
//

import Foundation

extension Array: LosslessStringConvertible where Element == UInt8 {
    public init?(_ description: String) {
        self = []
    }
}

extension UnsafeMutablePointer: LosslessStringConvertible, CustomStringConvertible where Pointee == UInt8 {
    public var description: String {
        return "Unsafe mutable pointer"
    }

    public init?(_ description: String) {
        return nil
    }
}

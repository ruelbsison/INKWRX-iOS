//
//  ConnectionUserVersion.swift
//  Inkworks
//
//  Created by Jamie Duggan on 04/04/2017.
//  Copyright © 2017 Destiny Wireless. All rights reserved.
//

import Foundation
import SQLite

extension Connection {
    public var userVersion : Int32 {
        get {
            return Int32(try! scalar("pragma user_version") as! Int64)
        }
        set {
            try! run("pragma user_version=\(newValue)")
        }
    }
}

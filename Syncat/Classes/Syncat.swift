//
//  Syncat.swift
//  Pods-Syncat_Example
//
//  Created by Layman on 2018/4/2.
//

import Foundation
import RealmSwift

let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String

func objectType(forName typeName: String) -> Object.Type? {
    if let clazz = NSClassFromString("\(namespace).\(typeName)") as? Object.Type {
        return clazz
    } else {
        return NSClassFromString(typeName) as? Object.Type
    }
}

func substring(_ string: String, offset: Int) -> String {
    let startIndex = string.index(string.startIndex, offsetBy: offset)
    return String(string[startIndex...])
}

//
//  Dictionary+JSONSerializable.swift
//  Common
//
//  Created by binea on 2017/3/9.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

extension Dictionary {
    
    public func toJSONString(writeOptions: JSONSerialization.WritingOptions = [.prettyPrinted]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: writeOptions) else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    public static func parseFrom(JSONString jsonString: String, readOptions: JSONSerialization.ReadingOptions = []) -> Dictionary<Key, Value>? {
        guard let data = jsonString.data(using: .utf8), let jsonObject = try? JSONSerialization.jsonObject(with: data, options: readOptions) else { return nil }
        return jsonObject as? Dictionary<Key,Value>
    }
}

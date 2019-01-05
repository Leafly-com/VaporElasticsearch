//
//  BoundingBox.swift
//  Leafly
//
//  Created by Kyle Begeman on 1/4/19.
//  Copyright © 2019 Leafly Holdings, Inc. All rights reserved.
//

import Foundation

/**
 The `BoundingBox` query is a query allowing to filter hits based on a point location using a bounding box..

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-geo-bounding-box-query.html)
 */

public struct Box {
    var topLeft: CGPoint
    var bottomRight: CGPoint
}

public struct BoundingBox: QueryElement {
    /// :nodoc:
    public static var typeKey = QueryElementMap.location

    public let field: String
    public let topLeft: [Double]
    public let bottomRight: [Double]

    public init(field: String, topLeft: [Double], bottomRight: [Double]) {
        self.field = field
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }

    private struct Inner: Codable {
        let topLeft: [Double]
        let bottomRight: [Double]
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        let inner = BoundingBox.Inner(topLeft: topLeft, bottomRight: bottomRight)
        try container.encode(inner, forKey: DynamicKey(stringValue: field)!)
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        let key = container.allKeys.first
        self.field = key!.stringValue

        let innerDecoder = try container.superDecoder(forKey: key!)
        let inner = try BoundingBox.Inner(from: innerDecoder)
        self.topLeft = inner.topLeft
        self.bottomRight = inner.bottomRight
    }
}

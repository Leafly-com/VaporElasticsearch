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

public struct BoundingBox: QueryElement {
    /// :nodoc:
    public static var typeKey = QueryElementMap.location

    public let field: String
    public let lat: Double
    public let lon: Double

    public init(field: String, lat: Double, lon: Double) {
        self.field = field
        self.lat = lat
        self.lon = lon
    }

    private struct Inner: Codable {
        let lat: Double
        let lon: Double
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        let inner = BoundingBox.Inner(lat: lat, lon: lon)
        try container.encode(inner, forKey: DynamicKey(stringValue: field)!)
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        let key = container.allKeys.first
        self.field = key!.stringValue

        let innerDecoder = try container.superDecoder(forKey: key!)
        let inner = try BoundingBox.Inner(from: innerDecoder)
        self.lat = inner.lat
        self.lon = inner.lon
    }
}

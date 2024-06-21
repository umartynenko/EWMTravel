//
//  Earthquake.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 01.06.2024.
//

import Foundation
import MapKit


struct SeismicEvent: Identifiable, Decodable {
    let id: String
    let title: String
    let coordinate: CLLocationCoordinate2D
    let magnitude: Double
    let time: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case properties
        case id
        case geometry
    }
    
    enum PropertiesKeys: String, CodingKey {
        case mag
        case title
        case time
    }
    
    enum GeometryKeys: String, CodingKey {
        case coordinates
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        let properties = try container.nestedContainer(keyedBy: PropertiesKeys.self, forKey: .properties)
        magnitude = try properties.decode(Double.self, forKey: .mag)
        title = try properties.decode(String.self, forKey: .title)
        time = try properties.decode(TimeInterval.self, forKey: .time)
        
        let geometry = try container.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
        let coordinates = try geometry.decode([Double].self, forKey: .coordinates)
        coordinate = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }
}


struct USGSResponse: Decodable {
    let features: [SeismicEvent]
}


extension SeismicEvent: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
}

//
//  FireDataViewModel.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 05.06.2024.
//

import Foundation
import Combine


class FireDataViewModel: ObservableObject {
    @Published var fireData: [FireData] = []
    
    private var cancellable: AnyCancellable?
    
    func loadFireData(interval: String) {
        guard let url = URL(string: "https://firms2.modaps.eosdis.nasa.gov/data/active_fire/noaa-21-viirs-c2/csv/J2_VIIRS_C2_Global_\(interval).csv") else {
            print("Invalid URL")
            return
        }
       
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
                    .map { $0.data }
                    .subscribe(on: DispatchQueue.global(qos: .background)) // Ensure network request runs on a background thread
                    .map { String(data: $0, encoding: .utf8) ?? "" }
                    .flatMap { data -> AnyPublisher<[FireData], Never> in
                        Future { promise in
                            let fireData = self.parseCSV(data)
                            promise(.success(fireData))
                        }
                        .subscribe(on: DispatchQueue.global(qos: .background))
                        .eraseToAnyPublisher()
                    }
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: [])
                    .assign(to: \.fireData, on: self)
            }
    
    private func parseCSV(_ data: String) -> [FireData] {
        var fireData = [FireData]()
        
        let rows = data.split(separator: "\n")
        
        for row in rows.dropFirst() {
            let columns = row.split(separator: ",")
            
            if columns.count >= 13 {
                let fire = FireData(
                    latitude: Double(columns[0]) ?? 0.0,
                    longitude: Double(columns[1]) ?? 0.0,
                    brightness: Double(columns[2]) ?? 0.0,
                    scan: Double(columns[3]) ?? 0.0,
                    track: Double(columns[4]) ?? 0.0,
                    acqDate: String(columns[5]),
                    acqTime: String(columns[6]),
                    satellite: String(columns[7]),
                    confidence: String(columns[8]),
                    version: String(columns[9]),
                    brightT31: Double(columns[10]) ?? 0.0,
                    frp: Double(columns[11]) ?? 0.0,
                    dayNight: String(columns[12])
                )
                
                if fire.confidence == "high" || fire.confidence == "low"{
                    if fire.brightness >= 300 && fire.frp >= 20 && fire.brightT31 >= 290 {
                        fireData.append(fire)
                    }
                }
            }
        }
        print(fireData)
        print(fireData.count)
        return fireData
    }
}


class StringDecoder: TopLevelDecoder {
    typealias Input = Data
    
    func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable {
        return String(data: from, encoding: .utf8) as! T
    }
}

//
//  EarthquakeViewModel.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 01.06.2024.
//

import Foundation
import Combine
import CoreLocation


class EarthquakeViewModel: ObservableObject {
    @Published var seismicEvents: [SeismicEvent] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchSeismicData(for timePeriod: String = "") {
        guard let url = URL(string: "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=now-\(timePeriod)&endtime=now") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: USGSResponse.self, decoder: JSONDecoder())
            .map { $0.features }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
//            .assign(to: \.seismicEvents, on: self)
            .sink { [weak self] seismicEvents in
                self?.seismicEvents = seismicEvents
            }
            .store(in: &cancellables)
    }
}

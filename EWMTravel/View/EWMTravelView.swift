//
//  ContentView.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 01.06.2024.
//
//


import SwiftUI
import MapKit
import Combine
import Firebase


struct EWMTravelView: View {
    @State private var camerPosition: MapCameraPosition = .region(.myRegion)
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchResults: [MKMapItem] = []
    @State private var mapSelection: MKMapItem?
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var viewingRegion: MKCoordinateRegion?
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1
    @State private var selectedTimePeriod: String = ""
    @State private var selectedTimePeriodForFire: String = ""
    @State private var isMenuVisible: Bool = false
    @State private var selectedActivityType = ""
    
    @Namespace private var locatonSpace
    
    @StateObject private var viewModel = EarthquakeViewModel()
    @StateObject private var fireViewModel = FireDataViewModel()
    
    let nameEvents = [
        ("earthquakes", "mountain.2", "Землетрясения"),
        ("fires", "flame", "Пожары"),
    ]
    
    let timePeriodsForEarthquakes = [
        ("1hour", "clock", "1 час"),
        ("1day", "sun.max", "1 день"),
        ("1week", "calendar", "1 неделя"),
        ("1month", "calendar.badge.plus", "1 месяц"),
    ]
    
    let timePeriodsForFire = [
        ("24h", "clock", "24 часа"),
        ("48h", "clock", "48 часов"),
        ("7d", "sun.max", "7 дней"),
    ]
    
    var body: some View {
            NavigationStack {
                VStack {
                    if isMenuVisible {
                        VStack {
                            HStack {
                                ForEach(nameEvents, id: \.0) { nameEvents in
                                    Button(action: {
                                        selectedActivityType = nameEvents.0
                                    }) {
                                        VStack {
                                            Image(systemName: nameEvents.1)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 24)
                                                .font(.headline)
                                                .padding()
                                                .background(selectedActivityType == nameEvents.0 ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                            Text(nameEvents.2)
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical)
                            if selectedActivityType == "earthquakes" {
                                HStack {
                                    ForEach(timePeriodsForEarthquakes, id: \.0) { period in
                                        Button(action: {
                                            selectedTimePeriod = period.0
                                            withAnimation {
                                                isMenuVisible.toggle()
                                            }
                                        }) {
                                            VStack {
                                                Image(systemName: period.1)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 24)
                                                    .padding()
                                                    .background(selectedTimePeriod == period.0 ? Color.blue : Color.gray)
                                                    .foregroundColor(.white)
                                                    .clipShape(Circle())
                                                
                                                Text(period.2)
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .padding(.horizontal, 5)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical)
                            } else if selectedActivityType == "fires" {
                                HStack {
                                    ForEach(timePeriodsForFire, id: \.0) { period in
                                        Button(action: {
                                            selectedTimePeriodForFire = period.0
                                            withAnimation {
                                                isMenuVisible.toggle()
                                            }
                                        }) {
                                            VStack {
                                                Image(systemName: period.1)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 24)
                                                    .padding()
                                                    .background(selectedTimePeriodForFire == period.0 ? Color.blue : Color.gray)
                                                    .foregroundColor(.white)
                                                    .clipShape(Circle())
                                                
                                                Text(period.2)
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .padding(.horizontal, 5)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical)
                            }
                        }
                    }
                    
                    Map(position: $camerPosition, selection: $mapSelection, scope: locatonSpace) {
                        Marker("", systemImage: "smallcircle.filled.circle.fill", coordinate: .myLocation)
                            .tint(.blue)
                            .annotationTitles(.hidden)
                        
                        ForEach(searchResults.filter { isWithinViewingRegion($0.placemark.coordinate) }, id: \.self) { mapItem in
                            let placemark = mapItem.placemark
                            
                            Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                                .tint(.blue)
                        }
                        
                        ForEach(viewModel.seismicEvents.filter { isWithinViewingRegion($0.coordinate) }) { event in
                            Annotation(String(event.title), coordinate: event.coordinate) {
                                let magnitude = event.magnitude
                                
                                EarthquakeAnnotationView(magnitude: magnitude)
                            }
                        }
                        
                        ForEach(fireViewModel.fireData.filter { isWithinViewingRegion(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)) }) { event in
                            Annotation("\(event.latitude), \(event.longitude)", coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)) {
                                let frp = event.frp
                                let markerSize = calculateMarkerSize(for: frp)
                                
                                FireAnnotationView(size: markerSize, level: event.confidence, scan: event.scan, track: event.track)
                            }
                        }
                        UserAnnotation()
                    }
                    .onMapCameraChange { ctx in
                        viewingRegion = ctx.region
                    }
                    .overlay(alignment: .bottomTrailing) {
                        VStack(spacing: 15) {
                            MapPitchToggle(scope: locatonSpace)
                            MapUserLocationButton(scope: locatonSpace)
                        }
                        .buttonBorderShape(.circle)
                        .padding()
                    }
                    .mapScope(locatonSpace)
                    .mapStyle(.standard(elevation: .realistic))
                    
                    
                    .navigationTitle("EWMTravel")
                    .navigationBarTitleDisplayMode(.inline)
                    .searchable(text: $searchText, isPresented: $showSearch, prompt: "Поиск")
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                    .sheet(isPresented: $showDetails) {
                        mapDetails()
                            .presentationDetents([.height(300)])
                            .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
                            .interactiveDismissDisabled(true)
                    }
                    .overlay(alignment: .topLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuVisible.toggle()
                            }
                        }) {
                            Image(systemName: isMenuVisible ? "chevron.up.circle" : "chevron.down.circle")
                                .font(.system(size: 35).weight(.light))
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                }
            }
            .onSubmit(of: .search) {
                Task {
                    guard !searchText.isEmpty else { return }
                    await searchPlaces()
                }
            }
            .onChange(of: showSearch, initial: false) {
                if (!showSearch) {
                    searchResults.removeAll(keepingCapacity: false)
                    showDetails = false
                }
            }
            .onChange(of: mapSelection) { oldValue, newValue in
                withAnimation(.snappy) {
                    showDetails = newValue != nil
                }
                fetchLookAroundPreview()
            }
            .onChange(of: selectedTimePeriod) {
                viewModel.fetchSeismicData(for: selectedTimePeriod)
            }
            .onChange(of: selectedTimePeriodForFire) {
                fireViewModel.loadFireData(interval: selectedTimePeriodForFire)
            }
            .onChange(of: selectedActivityType) { oldValue, newValue in
                if newValue == "earthquakes" {
                    fireViewModel.fireData = []
                    selectedTimePeriodForFire = ""
                } else {
                    viewModel.seismicEvents = []
                    selectedTimePeriod = ""
                }
            }
    }
    
    @ViewBuilder
    func mapDetails() -> some View {
        VStack(spacing: 15) {
            ZStack {
                if (lookAroundScene == nil) {
                    ContentUnavailableView("Предварительный просмотр недоступен", systemImage: "eye.slash")
                } else {
                    LookAroundPreview(scene: $lookAroundScene)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(alignment: .topTrailing) {
                Button(action: {
                    showDetails = false
                    withAnimation(.snappy) {
                        mapSelection = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
                .foregroundColor(.blue)
                .padding(5)
                .background(.ultraThickMaterial, in: Circle())
                .padding(5)
            }
            
            if let selectedPlace = mapSelection {
                HStack(spacing: 15) {
                    VStack(alignment: .leading) {
                        Text(selectedPlace.name ?? "Unknown place")
                            .font(.headline)
                        Text(selectedPlace.placemark.title ?? "Missing address")
                            .font(.subheadline)
                    }
                    
                    Spacer(minLength: 0)
                    
                    Button(action: {
                        showInMaps(selectedPlace)
                    }) {
                        Image(systemName: "arrow.turn.up.right")
                            .font(.title3)
                            .padding(10)
                    }
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.large)
                }
                .padding(.horizontal, 8)
            }
        }
        .padding()
    }
    
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .myRegion
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            searchResults = response.mapItems
            mapSelection = nil
        } catch {
            print("Error searching places: \(error.localizedDescription)")
        }
    }
    
    func fetchLookAroundPreview() {
        guard let selectedPlace = mapSelection else { return }
        
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedPlace)
            
            do {
                lookAroundScene = try await request.scene
            } catch {
                print("Error fetching Look Around scene: \(error.localizedDescription)")
            }
        }
    }
    
    func showInMaps(_ mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    func isWithinViewingRegion(_ coordinate: CLLocationCoordinate2D) -> Bool {
        guard let region = viewingRegion else { return false }
        
        let latDelta = region.span.latitudeDelta / 2.0
        let lonDelta = region.span.longitudeDelta / 2.0
        
        let minLat = region.center.latitude - latDelta
        let maxLat = region.center.latitude + latDelta
        let minLon = region.center.longitude - lonDelta
        let maxLon = region.center.longitude + lonDelta
        
        return (minLat...maxLat).contains(coordinate.latitude) &&
        (minLon...maxLon).contains(coordinate.longitude)
    }
    
    func calculateMarkerSize(for frp: Double) -> CGFloat {
        // Например, предположим, что размер маркера будет пропорционален FRP
        // Чем выше значение FRP, тем больше маркер
        let baseSize: CGFloat = 10 // Базовый размер маркера
        let scaleFactor: CGFloat = 0.1 // Масштабный коэффициент, чтобы увеличить или уменьшить маркер в зависимости от FRP
        
        return baseSize + CGFloat(frp) * scaleFactor
    }
}


extension CLLocationCoordinate2D {
    static let myLocation = CLLocationCoordinate2D(latitude: 45.04703, longitude: 39.12763)
}


extension MKCoordinateRegion {
    static var myRegion: MKCoordinateRegion {
        return .init(center: .myLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}


#Preview {
    EWMTravelView()
}

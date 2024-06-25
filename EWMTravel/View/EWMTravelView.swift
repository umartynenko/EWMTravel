//
//  EWMTravelView.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 01.06.2024.
//
//

import SwiftUI
import MapKit
import Combine
import Firebase

class ClusterAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?) {
        self.coordinate = coordinate
        self.title = title
    }
}

struct EWMTravelView: View {
    @State private var mapView = MKMapView()
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
    @State var mapType: MapStyle = .standard(elevation: .realistic)
    @State var standartType: Bool = true
    @State private var colorScheme: ColorScheme = .light
    
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
                        eventSelectionView
                        timePeriodSelectionView
                    }
                }
                
                MapView(mapView: $mapView, searchResults: $searchResults, viewingRegion: $viewingRegion, viewModel: viewModel, fireViewModel: fireViewModel, selectedActivityType: $selectedActivityType, selectedTimePeriod: $selectedTimePeriod, selectedTimePeriodForFire: $selectedTimePeriodForFire)
                    .onMapCameraChange { ctx in
                        viewingRegion = ctx.region
                    }
                    .overlay(alignment: .bottomTrailing) {
                        bottomOverlayView
                    }
                    .mapScope(locatonSpace)
                    .mapStyle(mapType)
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
                        toggleMenuButton
                    }
            }
        }
        .onSubmit(of: .search) {
            Task {
                guard !searchText.isEmpty else { return }
                searchResults = await searchPlaces(query: searchText, region: .myRegion)
                mapSelection = nil
            }
        }
        .preferredColorScheme(colorScheme)
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
            Task {
                lookAroundScene = await fetchLookAroundPreview(for: newValue!)
            }
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
    private var eventSelectionView: some View {
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
    }
    
    @ViewBuilder
    private var timePeriodSelectionView: some View {
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
                                .background(
                                    selectedTimePeriodForFire == period.0 ? Color.blue : Color.gray
                                )
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
    
    @ViewBuilder
    private var bottomOverlayView: some View {
        VStack(spacing: 15) {
            MapPitchToggle(scope: locatonSpace)
            MapUserLocationButton(scope: locatonSpace)
            Button {
                switchTypeMap(standartType: &standartType, mapType: &mapType, colorScheme: &colorScheme)
            } label: {
                Image(systemName: standartType ? "map" : "map.fill")
                    .font(.system(size: 22))
                    .padding(10)
                    .background(Color("mapType").opacity(0.9))
                    .clipShape(Circle())
            }
        }
        .buttonBorderShape(.circle)
        .padding()
    }
    
    @ViewBuilder
    private var toggleMenuButton: some View {
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
    
    @ViewBuilder
    func mapDetails() -> some View {
        VStack(spacing: 15) {
            ZStack {
                if (lookAroundScene == nil) {
                    ContentUnavailableView("Предварительный просмотр недоступен", systemImage: "eye.slash")
                } else {
                    LookAroundPreview(initialScene: lookAroundScene!)
                }
                
                Button(action: {
                    showDetails = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 35).weight(.light))
                        .foregroundColor(.white)
                        .background {
                            Circle()
                                .fill(Color.black)
                        }
                        .symbolRenderingMode(.palette)
                }
                .padding(6)
            }
            .background(alignment: .top) {
                Rectangle()
                    .fill(Color.black.gradient)
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
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
}

extension CLLocationCoordinate2D {
    static let myLocation = CLLocationCoordinate2D(latitude: 45.04703, longitude: 39.12763)
}

extension MKCoordinateRegion {
    static var myRegion: MKCoordinateRegion {
        return .init(center: .myLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}

struct MapView: UIViewRepresentable {
    @Binding var mapView: MKMapView
    @Binding var searchResults: [MKMapItem]
    @Binding var viewingRegion: MKCoordinateRegion?
    
    @ObservedObject var viewModel: EarthquakeViewModel
    @ObservedObject var fireViewModel: FireDataViewModel
    
    @Binding var selectedActivityType: String
    @Binding var selectedTimePeriod: String
    @Binding var selectedTimePeriodForFire: String
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView
                if (clusterView == nil) {
                    clusterView = MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: "cluster")
                }
                
                clusterView?.markerTintColor = .blue
                clusterView?.glyphText = "\(cluster.memberAnnotations.count)"
                
                return clusterView
            } else if let annotation = annotation as? ClusterAnnotation {
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                    view?.canShowCallout = true
                }
                view?.markerTintColor = .red
                return view
            }
            return nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        let annotations = searchResults.map { ClusterAnnotation(coordinate: $0.placemark.coordinate, title: $0.name) }
        uiView.addAnnotations(annotations)
        
        let earthquakeAnnotations = viewModel.seismicEvents.map { ClusterAnnotation(coordinate: $0.coordinate, title: $0.title) }
        uiView.addAnnotations(earthquakeAnnotations)
        
        let fireAnnotations = fireViewModel.fireData.map {
                    ClusterAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                        title: $0.satellite
                    )
                }
        uiView.addAnnotations(fireAnnotations)
        
        if let region = viewingRegion {
            uiView.setRegion(region, animated: true)
        }
    }
}

func switchTypeMap(standartType: inout Bool, mapType: inout MapStyle, colorScheme: inout ColorScheme) {
    standartType.toggle()
    if standartType {
        mapType = .standard(elevation: .realistic)
        colorScheme = .light
    } else {
        mapType = .imagery(elevation: .realistic)
        colorScheme = .dark
    }
}

func searchPlaces(query: String, region: MKCoordinateRegion) async -> [MKMapItem] {
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = query
    searchRequest.region = region
    
    let search = MKLocalSearch(request: searchRequest)
    do {
        let response = try await search.start()
        return response.mapItems
    } catch {
        print("Error searching for places: \(error.localizedDescription)")
        return []
    }
}

func fetchLookAroundPreview(for mapItem: MKMapItem) async -> MKLookAroundScene? {
    let request = MKLookAroundSceneRequest(mapItem: mapItem)
    do {
        let lookAroundScene = try await request.scene
        return lookAroundScene
    } catch {
        print("Error fetching Look Around scene: \(error.localizedDescription)")
        return nil
    }
}

func showInMaps(_ mapItem: MKMapItem) {
    mapItem.openInMaps(launchOptions: [
        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ])
}


#Preview {
    EWMTravelView()
}

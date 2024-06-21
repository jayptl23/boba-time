import SwiftUI
import MapKit
import Combine

final class DebounceObject: ObservableObject {
    @Published var text: String = ""
    @Published var debouncedText: String = ""
    private var bag = Set<AnyCancellable>()
    
    public init(dueTime: TimeInterval = 0.5) {
        $text
            .removeDuplicates()
            .debounce(for: .seconds(dueTime), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.debouncedText = value
            })
            .store(in: &bag)
    }
}

struct ContentView: View {
    
    @EnvironmentObject var localSearchService: LocalSearchService
    
    @StateObject var debounceObject = DebounceObject()
    @StateObject var vm = BusinessViewModel(dataService: DataService())
    @State var isPinSelected = false
    @State var showSearchResults: Bool = false
    
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack {
                mapLayer
                    .cornerRadius(5)
                    .overlay(alignment: .topLeading) {
                        VStack(spacing: 0) {
                            searchBarView
                            
//                            if isSearchFocused &&
//                                !debounceObject.text.isEmpty &&
//                                showSearchResults &&
//                                !localSearchService.landmarks.isEmpty {
//                                    searchResultsView
//                            }
                            
                            if isSearchFocused && !debounceObject.text.isEmpty {
                                searchResultsView
                            }
                        }
                    }
                
                Spacer()
                
                if vm.isLoading {
                    ProgressView()
                } else {
                    bobaShopsView
                }
            }
        }
        .task {
            await vm.fetchBusinesses(region: localSearchService.region)
        }
        .alert(isPresented: $vm.hasError, error: vm.error) {
            Button("Retry") {
                Task {
                    await vm.fetchBusinesses(region: localSearchService.region)
                }
            }
            
        }
        .onTapGesture {
            isSearchFocused.toggle()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocalSearchService())
    }
}

extension ContentView {
    
    private var searchBarView: some View {
        TextField("Change Location", text: $debounceObject.text)
            .focused($isSearchFocused)
            .autocorrectionDisabled()
            .textFieldStyle(.roundedBorder)
            .onChange(of: debounceObject.debouncedText, perform: { text in
                if text.isEmpty {
                    return
                }
                showSearchResults = true
                localSearchService.search(query: text)
            })
            .overlay(alignment: .trailing) {
                Image(systemName: "x.circle")
                    .font(.title2)
                    .padding(5)
                    .opacity(debounceObject.text.isEmpty ? 0 : 100)
                    .onTapGesture {
                        debounceObject.text = ""
                    }
            }
    }
    
    private var searchResultsView: some View {
        List(localSearchService.landmarks) { landmark in
            VStack(alignment: .leading) {
                Text(landmark.name)
                Text(landmark.title)
                    .opacity(0.5)
            }
            .onTapGesture {
                localSearchService.landmark = landmark
                debounceObject.text = landmark.name
                withAnimation {
                    localSearchService.region = MKCoordinateRegion.regionFromLandmark(landmark)
                }
                showSearchResults = false
                Task {
                    await vm.fetchBusinesses(region: localSearchService.region)
                }
            }
        }
        .listStyle(.plain)
        .background(.ultraThinMaterial)
    }
    
    private var bobaShopsView: some View {
        VStack {
            VStack {
                Text(localSearchService.landmark?.name ?? "Near You")
                Text(localSearchService.landmark?.title ?? "")
            }
            .font(.headline)
            .fontWeight(.semibold)
            
            ScrollView {
                LazyVStack {
                    ForEach(vm.businesses, id: \.id) { shop in
                        Card(business: shop)
                    }
                }
            }
        }
        .padding()
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: $localSearchService.region,
            //                    interactionModes: [],
            showsUserLocation: true,
            annotationItems: vm.annotations,
            annotationContent: { location in
            //MapPin(coordinate: location.coordinate)
            MapMarker(coordinate: location.coordinate, tint: Color.purple)
            
            // MARK: https://developer.apple.com/forums/thread/718697 known bug with using custom annotation
            //                    MapAnnotation(coordinate: location.coordinate, content: {
            //                        AnnotationMarker(name: location.name)
            //                    })
        }
        )
    }
}

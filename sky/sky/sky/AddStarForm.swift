import SwiftUI
import CoreLocation

struct AddStarForm: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isShowingMap = false
    @State private var starName: String = ""
    @State private var starDescription: String = ""
    @State private var selectedDate = Date()  // New date state
    
    var onSave: (CLLocationCoordinate2D, String, String, Date) -> Void  // Added Date
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Star Location")) {
                        Button(action: { isShowingMap = true }) {
                            HStack {
                                Text("Pick a celestial spot")
                                Spacer()
                                if let coordinate = selectedCoordinate {
                                    Text(String(format: "Lat: %.2f, Lon: %.2f", coordinate.latitude, coordinate.longitude))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Star's Name")) {
                        TextField("What will you call this star?", text: $starName)
                    }
                    
                    Section(header: Text("Memory")) {
                        TextField("Write a special story...", text: $starDescription)
                    }
                    
                    Section(header: Text("Memory Date")) {
                        DatePicker("Choose the day this star was born", selection: $selectedDate, displayedComponents: .date)
                    }
                }
                
                Button(action: {
                    if let coordinate = selectedCoordinate {
                        onSave(coordinate, starName, starDescription, selectedDate)
                        dismiss()
                    }
                }) {
                    Text("Add This Star")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCoordinate != nil && !starName.isEmpty ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(selectedCoordinate == nil || starName.isEmpty)
            }
            .navigationTitle("Create Your Star")
            .navigationBarItems(leading: Button("Dismiss") { dismiss() })
            .sheet(isPresented: $isShowingMap) {
                AddLocationSheet { coordinate in
                    selectedCoordinate = coordinate
                    isShowingMap = false
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

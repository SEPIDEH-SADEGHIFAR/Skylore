import SwiftUI
import CoreLocation

struct AddStarForm: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isShowingMap = false
    @State private var starName: String = ""
    @State private var starDescription: String = ""
    
    var onSave: (CLLocationCoordinate2D, String, String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Location")) {
                        Button(action: { isShowingMap = true }) {
                            HStack {
                                Text("Choose Location")
                                Spacer()
                                if let coordinate = selectedCoordinate {
                                    Text(String(format: "Lat: %.2f, Lon: %.2f", coordinate.latitude, coordinate.longitude))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    Section(header: Text("Star Name")) {
                        TextField("Enter star name", text: $starName)
                    }
                    Section(header: Text("Description")) {
                        TextField("Enter description", text: $starDescription)
                    }
                }
                
                // The Save Star Button Outside the Form
                Button(action: {
                    if let coordinate = selectedCoordinate {
                        onSave(coordinate, starName, starDescription)
                        dismiss()
                    }
                }) {
                    Text("Save Star")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCoordinate != nil && !starName.isEmpty ? Color.blue : Color.gray) // Blue when enabled, gray when disabled
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(selectedCoordinate == nil || starName.isEmpty) // Disable button when necessary
            }
            .navigationTitle("Add New Star")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .sheet(isPresented: $isShowingMap) {
                AddLocationSheet { coordinate in
                    selectedCoordinate = coordinate
                    isShowingMap = false
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

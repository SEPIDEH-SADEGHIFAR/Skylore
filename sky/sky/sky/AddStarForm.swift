import SwiftUI
import CoreLocation

struct AddStarForm: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isShowingMap = false
    @State private var starName: String = ""
    @State private var starDescription: String = ""
    @State private var selectedDate = Date()
    
    var onSave: (CLLocationCoordinate2D, String, String, Date) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Deep Space Background
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
                GlitteringStarsBackground().opacity(0.5)
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // Location Picker Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("COORDINATES")
                                .font(.caption).foregroundColor(.gray).tracking(2)
                            
                            Button(action: { isShowingMap = true }) {
                                HStack {
                                    Image(systemName: "map.fill").foregroundColor(.cyan)
                                    Text(selectedCoordinate != nil ? "Location Locked" : "Chart a Celestial Spot")
                                        .foregroundColor(selectedCoordinate != nil ? .white : .gray)
                                    Spacer()
                                    if let coordinate = selectedCoordinate {
                                        Text(String(format: "%.2f, %.2f", coordinate.latitude, coordinate.longitude))
                                            .font(.caption)
                                            .foregroundColor(.cyan)
                                    } else {
                                        Image(systemName: "chevron.right").foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                        }
                        
                        // Details Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DESIGNATION",).font(.caption).foregroundColor(.gray).tracking(2)
                            
                            TextField("Enter Star Name...", text: $starName)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            
                            TextField("Log a memory...", text: $starDescription, axis: .vertical)
                                .lineLimit(4...8)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                        
                        // Temporal Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TEMPORAL DATA").font(.caption).foregroundColor(.gray).tracking(2)
                            
                            DatePicker("Discovery Date", selection: $selectedDate, displayedComponents: .date)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                .colorScheme(.dark) // Forces white text on the picker
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                        
                        Spacer(minLength: 30)
                        
                        // Save Button
                        Button(action: {
                            if let coordinate = selectedCoordinate {
                                onSave(coordinate, starName, starDescription, selectedDate)
                                dismiss()
                            }
                        }) {
                            Text("INITIATE STAR")
                                .font(.headline).tracking(1.5)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedCoordinate != nil && !starName.isEmpty ? Color.cyan : Color.white.opacity(0.1))
                                .foregroundColor(selectedCoordinate != nil && !starName.isEmpty ? .black : .gray)
                                .cornerRadius(15)
                                .shadow(color: selectedCoordinate != nil && !starName.isEmpty ? .cyan.opacity(0.5) : .clear, radius: 10)
                        }
                        .disabled(selectedCoordinate == nil || starName.isEmpty)
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("New Discovery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $isShowingMap) {
                AddLocationSheet { coordinate in
                    selectedCoordinate = coordinate
                    isShowingMap = false
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

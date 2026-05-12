import SwiftUI
import CoreLocation

struct AddStarForm: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isShowingMap = false
    @State private var starName = ""
    @State private var starDescription = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory: StarCategory = .memory
    @State private var orbPulse = false

    var onSave: (CLLocationCoordinate2D, String, String, Date, StarCategory) -> Void

    private var canSave: Bool { selectedCoordinate != nil && !starName.isEmpty }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.04, green: 0.04, blue: 0.09).ignoresSafeArea()
                GlitteringStarsBackground().opacity(0.3)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── Hero orb ──────────────────────────────────────
                        orbPreview
                            .padding(.top, 12)
                            .padding(.bottom, 32)

                        // ── Sections ──────────────────────────────────────
                        VStack(spacing: 24) {
                            categorySection
                            locationSection
                            detailsSection
                            dateSection
                        }
                        .padding(.horizontal, 20)

                        // ── Save button ───────────────────────────────────
                        saveButton
                            .padding(.horizontal, 20)
                            .padding(.top, 32)
                            .padding(.bottom, 50)
                    }
                }
            }
            .navigationTitle("New Star")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(7)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $isShowingMap) {
                AddLocationSheet { coord in selectedCoordinate = coord }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: ── Hero orb ──────────────────────────────────────────────────

    private var orbPreview: some View {
        VStack(spacing: 14) {
            ZStack {
                // Outer soft halo
                Circle()
                    .fill(selectedCategory.color.opacity(0.08))
                    .frame(width: orbPulse ? 130 : 120, height: orbPulse ? 130 : 120)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: orbPulse)

                // Mid glow ring
                Circle()
                    .fill(selectedCategory.color.opacity(0.15))
                    .frame(width: 90, height: 90)

                // Core
                Circle()
                    .fill(selectedCategory.color.opacity(0.22))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .strokeBorder(selectedCategory.color.opacity(0.5), lineWidth: 1)
                    )

                // Icon
                Image(systemName: selectedCategory.icon)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(selectedCategory.color)
            }
            .onAppear { orbPulse = true }

            // Category name below orb
            Text(selectedCategory.label.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(selectedCategory.color.opacity(0.8))
                .tracking(3)
        }
        .animation(.spring(response: 0.4), value: selectedCategory)
    }

    // MARK: ── Category section ──────────────────────────────────────────

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Category")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(StarCategory.allCases, id: \.self) { cat in
                        categoryChip(cat)
                    }
                }
                .padding(.horizontal, 1) // prevent clip
            }
        }
    }

    private func categoryChip(_ cat: StarCategory) -> some View {
        let isSelected = selectedCategory == cat
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedCategory = cat
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: cat.icon)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? cat.color : .gray)

                Text(cat.label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? cat.color.opacity(0.16) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isSelected ? cat.color.opacity(0.6) : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: ── Location section ──────────────────────────────────────────

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Location")

            Button { isShowingMap = true } label: {
                HStack(spacing: 14) {
                    // Icon block
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedCategory.color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "map")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(selectedCategory.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedCoordinate != nil ? "Location selected" : "Pick on map")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(selectedCoordinate != nil ? .white : .gray)

                        if let c = selectedCoordinate {
                            Text(String(format: "%.4f°,  %.4f°", c.latitude, c.longitude))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(selectedCategory.color.opacity(0.8))
                        } else {
                            Text("Tap to open the map")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.25))
                        }
                    }

                    Spacer()

                    Image(systemName: selectedCoordinate != nil ? "checkmark.circle.fill" : "chevron.right")
                        .font(.system(size: selectedCoordinate != nil ? 18 : 13))
                        .foregroundColor(selectedCoordinate != nil ? selectedCategory.color : .gray.opacity(0.5))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            selectedCoordinate != nil
                                ? selectedCategory.color.opacity(0.4)
                                : Color.white.opacity(0.07),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: selectedCoordinate != nil)
        }
    }

    // MARK: ── Details section ───────────────────────────────────────────

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Details")

            VStack(spacing: 1) {
                // Name field
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 36, height: 36)
                        Image(systemName: selectedCategory.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    TextField("Name this star", text: $starName)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14, corners: [.topLeft, .topRight])

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .padding(.leading, 66)

                // Description field
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 36, height: 36)
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 2)

                    TextField("Write a memory or note…", text: $starDescription, axis: .vertical)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .lineLimit(4...7)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14, corners: [.bottomLeft, .bottomRight])
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
            )
        }
    }

    // MARK: ── Date section ──────────────────────────────────────────────

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Date")

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 36, height: 36)
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }

                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(selectedCategory.color)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
            )
        }
    }

    // MARK: ── Save button ───────────────────────────────────────────────

    private var saveButton: some View {
        Button {
            guard let coord = selectedCoordinate, !starName.isEmpty else { return }
            onSave(coord, starName, starDescription, selectedDate, selectedCategory)
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text("Add to Constellation")
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(0.3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if canSave {
                        selectedCategory.color
                    } else {
                        Color.white.opacity(0.07)
                    }
                }
            )
            .foregroundColor(canSave ? .black : Color.white.opacity(0.25))
            .cornerRadius(14)
            .shadow(
                color: canSave ? selectedCategory.color.opacity(0.35) : .clear,
                radius: 16, y: 6
            )
        }
        .disabled(!canSave)
        .animation(.easeInOut(duration: 0.2), value: canSave)
        .animation(.easeInOut(duration: 0.2), value: selectedCategory)
    }

    // MARK: ── Helpers ───────────────────────────────────────────────────

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundColor(Color.white.opacity(0.3))
            .tracking(2.5)
    }
}

// MARK: - Corner radius helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

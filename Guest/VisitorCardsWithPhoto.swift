import SwiftUI

// UPDATED VISITOR CARD WITH PHOTO
// Use this to replace VisitorRecordCard in StatsView and other places

struct VisitorCardWithPhoto: View {
    let visitor: Visitor
    let maroon = Color(red: 0.5, green: 0, blue: 0)
    
    var body: some View {
        HStack(spacing: 16) {
            // Photo or avatar
            if let photoData = visitor.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            } else {
                // Fallback avatar with initials
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                    Text(visitor.fullName.prefix(2).uppercased())
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(visitor.fullName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                
                Text(visitor.company)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("Pass: \(visitor.passNumber)")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    if visitor.checkOutTime == nil {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("Active")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// VISITOR ROW WITH PHOTO FOR DASHBOARD
struct VisitorRowWithPhoto: View {
    let visitor: Visitor
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
            
            // Photo thumbnail
            if let photoData = visitor.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(visitor.fullName.prefix(1).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(visitor.fullName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                HStack(spacing: 8) {
                    Text(visitor.company)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("Pass: \(visitor.passNumber)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("In:")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                Text(visitor.checkInTime.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 3)
    }
}

// VISITOR DETAIL VIEW WITH LARGE PHOTO
struct VisitorDetailCard: View {
    let visitor: Visitor
    @State private var showingFullPhoto = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Large photo section
            if let photoData = visitor.photoData,
               let uiImage = UIImage(data: photoData) {
                Button(action: {
                    showingFullPhoto = true
                }) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10)
                }
                .sheet(isPresented: $showingFullPhoto) {
                    fullPhotoView(image: uiImage)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue.opacity(0.5))
                        Text("No Photo")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Visitor info
            VStack(spacing: 12) {
                Text(visitor.fullName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text(visitor.company)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    InfoBadge(icon: "number", text: visitor.passNumber, color: .blue)
                    
                    if visitor.checkOutTime == nil {
                        InfoBadge(icon: "checkmark.circle.fill", text: "Active", color: .green)
                    } else {
                        InfoBadge(icon: "xmark.circle.fill", text: "Departed", color: .gray)
                    }
                }
            }
        }
        .padding()
    }
    
    private func fullPhotoView(image: UIImage) -> some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            .navigationTitle("Visitor Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingFullPhoto = false
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// VISITOR SEARCH RESULT WITH PHOTO
struct VisitorSearchResultWithPhoto: View {
    let visitor: Visitor
    
    var body: some View {
        HStack(spacing: 12) {
            // Photo
            if let photoData = visitor.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            } else {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                    Text(visitor.fullName.prefix(2).uppercased())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(visitor.fullName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                
                Text(visitor.company)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    Text("Pass: \(visitor.passNumber)")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.blue)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(visitor.phoneNumber)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if visitor.checkOutTime == nil {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Active")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    
                    Text("In: \(visitor.checkInTime.formatted(date: .omitted, time: .shortened))")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                } else {
                    Text("Departed")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

// Preview
struct VisitorCardWithPhoto_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            VisitorCardWithPhoto(visitor: Visitor(
                fullName: "Jane Smith",
                company: "Tesla",
                phoneNumber: "1234567890",
                purpose: "Meeting",
                passNumber: "AB-1234",
                checkInTime: Date()
            ))
            
            VisitorRowWithPhoto(visitor: Visitor(
                fullName: "John Doe",
                company: "SpaceX",
                phoneNumber: "0987654321",
                purpose: "Tour",
                passNumber: "CD-5678",
                checkInTime: Date()
            ))
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

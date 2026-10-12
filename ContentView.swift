import SwiftUI

struct ContentView: View {
    // storing roommate users from Supabase database
    @State private var roommates: [Roommate] = []
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            // displays roommates in vertical list
            List(roommates) { roommate in
                // allows you to see the selected roommate's chores
                NavigationLink {
                    ChoreListView(roommate: roommate)
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(AppColors.chambray)
                            .cornerRadius(12)
                        
                        Text(roommate.name)
                            .font(.title3)
                            .foregroundStyle(AppColors.clove)
                        
                        Spacer()
                    }
                    .padding(.vertical, 14)
                }
                .listRowBackground(Color.white)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.sandstone)
            .navigationTitle("ChoreLists")
            .tint(AppColors.clove)
            .toolbar {
                Button {
                    Task { await loadRoommates() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .task {
                await loadRoommates()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    // grabs roommate data from Supabase roommate database
    func loadRoommates() async {
        do {
            roommates = try await ChoreService.getRoommates()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

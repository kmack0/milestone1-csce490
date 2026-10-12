import SwiftUI

struct ChoreListView: View {
    // roommate selected by user
    let roommate: Roommate
    
    // stores the selected roommate's chores
    @State private var chores: [Chore] = []
    @State private var newChoreTitle = ""
    // boolean for adding a new chore for selected roommate
    @State private var showingAddChore = false
    
    var body: some View {
        List(chores) { chore in
            Button {
                Task {
                    await toggleChore(chore)
                }
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: chore.is_completed
                          ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(
                        chore.is_completed
                        ? AppColors.chambray : AppColors.clove
                    )
                    .frame(width: 44, height: 44)
                    
                    Text(chore.title)
                        .font(.title3)
                        .foregroundStyle(AppColors.clove)
                        .strikethrough(chore.is_completed)
                    
                    Spacer()
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.white)
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.sandstone)
        .navigationTitle("\(roommate.name)'s Chores")
        .tint(AppColors.clove)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    Task {
                        await loadChores()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                
                Button {
                    showingAddChore = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await loadChores()
        }
        .alert("Add Chore", isPresented: $showingAddChore) {
            TextField("Chore name", text: $newChoreTitle)
            
            Button("Cancel", role: .cancel) {
                newChoreTitle = ""
            }
            
            Button("Add") {
                Task {
                    await addChore()
                }
            }
        } message: {
            Text("Enter a chore for \(roommate.name).")
        }
    }
    
    // loads all chores assigned to selected roommate
    func loadChores() async {
        do {
            chores = try await ChoreService.getChores(
                roommateID: roommate.id
            )
        } catch {
            print("Error loading chores: \(error)")
        }
    }
    // updates a chore's completion status by toggling database in Supabase
    func toggleChore(_ chore: Chore) async {
        do {
            try await ChoreService.updateChore(
                choreID: chore.id,
                completed: !chore.is_completed
            )
            
            await loadChores()
        } catch {
            print("Error updating chore: \(error)")
        }
    }
    // function to add a chore for selected roommate
    func addChore() async {
        // saves new chore to database
        do {
            try await ChoreService.addChore(
                title: newChoreTitle,
                roommateID: roommate.id
            )
            newChoreTitle = ""
            await loadChores()
        } catch {
            print("Error adding chore: \(error)")
        }
    }
}



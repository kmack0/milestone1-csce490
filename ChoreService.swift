
import Foundation

@MainActor
struct ChoreService {
    
    // sends request from supabase postgresql
    // incorporated sql through URL instead of through
    // swift package
    
    private static func sendRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> Data {
        
        guard let url = URL(
            string: "\(SupabaseConfig.projectURL)/rest/v1/\(endpoint)"
        ) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        request.setValue(
            SupabaseConfig.publishableKey,
            forHTTPHeaderField: "apikey"
        )
        
        
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        
        request.httpBody = body
        
        let (data, response) =
        try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(
                data: data,
                encoding: .utf8
            ) ?? "Unknown error"
            
            throw NSError(
                domain: "Supabase",
                code: httpResponse.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: message
                ]
            )
        }
        
        return data
    }
    
    // function to get roommate from database by id
    
    static func getRoommates() async throws -> [Roommate] {
        
        let data = try await sendRequest(
            endpoint: "roommates?select=*"
        )
        
        return try JSONDecoder().decode(
            [Roommate].self,
            from: data
        )
    }
    
    // function to obtain chores from database
    // each chore is assigned to a roommate id
    
    static func getChores(
        roommateID: Int
    ) async throws -> [Chore] {
        
        let data = try await sendRequest(
            endpoint: "chores?select=*&roommate_id=eq.\(roommateID)"
        )
        
        return try JSONDecoder().decode(
            [Chore].self,
            from: data
        )
    }
    
    // function to add chore onto roommate's own chore list
    // determines roommates id and assigns chore to that id number
    
    static func addChore(
        title: String,
        roommateID: Int
    ) async throws {
        
        let newChore = NewChore(
            title: title,
            roommate_id: roommateID
        )
        
        let body = try JSONEncoder().encode(newChore)
        
        _ = try await sendRequest(
            endpoint: "chores",
            method: "POST",
            body: body
        )
    }
    
    // function to update if a chore has been completed or not
    // updates chores database "is_completed" boolean depending
    // on whether this function is toggled
    
    static func updateChore(
        choreID: Int,
        completed: Bool
    ) async throws {
        
        let update = ChoreCompletion(
            is_completed: completed
        )
        
        let body = try JSONEncoder().encode(update)
        
        _ = try await sendRequest(
            endpoint: "chores?id=eq.\(choreID)",
            method: "PATCH",
            body: body
        )
    }
}


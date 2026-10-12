import Foundation

struct Roommate: Identifiable, Decodable {
let id: Int
let name: String
}

struct Chore: Identifiable, Decodable {
let id: Int
let title: String
let roommate_id: Int
let is_completed: Bool
}

struct NewChore: Encodable {
let title: String
let roommate_id: Int
}

struct ChoreCompletion: Encodable {
let is_completed: Bool
}

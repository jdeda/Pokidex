import Foundation

struct PokemonClient {
  var fetchPokemon: @Sendable () -> AsyncStream<Pokemon>
  
  struct Pokemon: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageURL: URL
  }
}

extension PokemonClient {
  static var liveValue = Self.live
  static var previewValue = Self.preview
}
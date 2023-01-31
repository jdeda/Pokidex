import Foundation

struct PokemonClientAsync {
  var fetchPokemon: @Sendable () -> AsyncStream<Pokemon>
  var fetchPokemonConcurrently: @Sendable () -> AsyncStream<Pokemon>
  
  struct Pokemon: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageURL: URL
  }
}

extension PokemonClientAsync {
  static var liveValue = Self.live
  static var previewValue = Self.preview
}

import Foundation

struct PokemonClientAsync {
  var fetchPokemonSerial: @Sendable () -> AsyncStream<Pokemon>
  var fetchPokemonParallel: @Sendable () -> AsyncStream<Pokemon>
  
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

import Foundation
import Combine

struct PokemonClientCombine {
  var fetchPokemon: AnyPublisher<Pokemon, Never>
  var fetchPokemonParallel: AnyPublisher<Pokemon, Never>

  struct Pokemon: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageURL: URL
  }
}

extension PokemonClientCombine {
  static var liveValue = Self.live
  static var previewValue = Self.preview
}

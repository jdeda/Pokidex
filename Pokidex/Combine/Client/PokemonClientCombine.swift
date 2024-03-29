import Foundation
import Combine

struct PokemonClientCombine {
  var fetchPokemonSerial: AnyPublisher<Pokemon, Never>
  var fetchPokemonParallel: AnyPublisher<Pokemon, Never>

  struct Pokemon: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageURL: URL
    let url: URL
  }
}

extension PokemonClientCombine {
  static var liveValue = Self.live
  static var previewValue = Self.preview
}

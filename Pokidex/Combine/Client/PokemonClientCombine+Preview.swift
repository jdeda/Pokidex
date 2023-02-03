import Foundation
import Combine

extension PokemonClientCombine {
  static var preview = Self.init(
    fetchPokemonSerial: {
      return models.publisher.flatMap { pokemon in
        return Future.init { promise in
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            promise(Result.success(pokemon))
          }
        }
      }
      .eraseToAnyPublisher()
    }(),
    
    fetchPokemonParallel: {
      return models.publisher.flatMap { pokemon in
        return Future.init { promise in
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            promise(Result.success(pokemon))
          }
        }
      }
      .eraseToAnyPublisher()
    }())
}

// MARK: - Data
private let models: [PokemonClientCombine.Pokemon] = [
  .init(
    id: UUID(),
    name: "bulbasaur",
    imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!,
    url: URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!
  ),
  .init(
    id: UUID(),
    name: "ivysaur",
    imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png")!,
    url: URL(string: "https://pokeapi.co/api/v2/pokemon/2/")!
  ),
  .init(
    id: UUID(),
    name: "venusaur",
    imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png")!,
    url: URL(string: "https://pokeapi.co/api/v2/pokemon/3/")!
  ),
]

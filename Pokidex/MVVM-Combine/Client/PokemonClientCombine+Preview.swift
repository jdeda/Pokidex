import Foundation
import Combine

extension PokemonClientCombine {
  static var preview = Self.init(
    fetchPokemon: {
      let models: [Pokemon] = [
        .init(
          id: UUID(),
          name: "bulbasaur",
          imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!
        ),
        .init(
          id: UUID(),
          name: "ivysaur",
          imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png")!
        ),
        .init(
          id: UUID(),
          name: "venusaur",
          imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png")!
        ),
      ]
      
      let publisher = models.publisher.flatMap { pokemon in
        return Future.init { promise in
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            promise(Result.success(pokemon))
          }
        }
      }
        .eraseToAnyPublisher()
      
      return publisher
    }(),
    fetchPokemonConcurrently: {
      let models: [Pokemon] = [
        .init(
          id: UUID(),
          name: "bulbasaur",
          imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!
        ),
        .init(
          id: UUID(),
          name: "ivysaur",
          imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png")!
        ),
        .init(
          id: UUID(),
          name: "venusaur",
          imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png")!
        ),
      ]
      
      let publisher = models.publisher.flatMap { pokemon in
        return Future.init { promise in
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            promise(Result.success(pokemon))
          }
        }
      }
        .eraseToAnyPublisher()
      
      return publisher
    }())
}

// MARK: - Private

private extension PokemonClientCombine {
  struct Response: Codable {
    let results: [EachResult]
    
    enum CodingKeys: CodingKey {
      case results
    }
  }
  struct EachResult: Codable {
    let url: URL
    
    enum CodingKeys: CodingKey {
      case url
    }
  }
  struct PokemonDetails: Codable {
    let name: String
    let sprites: PokemonSprites
    
    enum CodingKeys: CodingKey {
      case name
      case sprites
    }
  }
  struct PokemonSprites: Codable {
    let front_default: URL
    
    enum CodingKeys: CodingKey {
      case front_default
    }
  }
}

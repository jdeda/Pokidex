import Foundation
import Combine

extension PokemonClientCombine {
  static var live = Self.init(fetchPokemon: {
    let publisher = URLSession.shared.dataTaskPublisher(for: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!)
      .map { data, response -> [URL] in
          guard
              let responseHTTP = response as? HTTPURLResponse,
              responseHTTP.statusCode == 200
          else { return [] }
          do {
              let response = try JSONDecoder().decode(Response.self, from: data)
              return response.results.map(\.url)
          } catch {
            return []
          }
      }
      .replaceError(with: [])
      .flatMap(\.publisher)
      .flatMap(URLSession.shared.dataTaskPublisher)
      .compactMap { data, response -> Pokemon? in
        guard
          let responseHTTP = response as? HTTPURLResponse,
          responseHTTP.statusCode == 200
        else { return nil }
        do {
          let pd = try JSONDecoder().decode(PokemonDetails.self, from: data)
          return .init(id: UUID(), name: pd.name, imageURL: pd.sprites.front_default)
        } catch {
          return nil
        }
      }
      .replaceError(with: Pokemon(id: UUID(), name: "", imageURL: URL(string: "foo")!))
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

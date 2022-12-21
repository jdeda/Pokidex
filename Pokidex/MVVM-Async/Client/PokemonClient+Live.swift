import Foundation

extension PokemonClient {
  
  /**
   This version connects to the pokeAPI:
   <https://pokeapi.co/>
   
   All the Pokémon data you'll ever need in one place,
   easily accessible through a modern RESTful API.
   */
  static var live: Self {
    .init(fetchPokemon: {
      AsyncStream { continuation in
        Task {
          let response = try await JSONDecoder().decode(
            Response.self,
            from: URLSession.shared.data(from: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!).0
          )
          
          for url in response.results.map(\.url) {
            let pokemonDetail = try await JSONDecoder().decode(
              PokemonDetails.self,
              from: URLSession.shared.data(from: url).0
            )
            let pokemon = Pokemon(
              id: UUID(),
              name: pokemonDetail.name,
              imageURL: pokemonDetail.sprites.front_default
            )
            continuation.yield(pokemon)
          }
        }
      }
    })
  }
}

// MARK: - Private

private extension PokemonClient { 
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

/**
 RESPONSE:
 {
 "count": 1154,
 "next": "https://pokeapi.co/api/v2/pokemon?offset=100&limit=100",
 "previous": null,
 "results": [
 {
 "name": "bulbasaur",
 "url": "https://pokeapi.co/api/v2/pokemon/1/"
 },
 {
 "name": "ivysaur",
 "url": "https://pokeapi.co/api/v2/pokemon/2/"
 },
 */

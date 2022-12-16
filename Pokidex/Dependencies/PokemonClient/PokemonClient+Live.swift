import Foundation

// API: https://pokeapi.co/
extension PokemonClient {
    static var live: Self {
    .init(fetchPokemon: {
      AsyncStream { continuation in
        Task {
          struct Response: Codable {
            let results: [PokemonResult]
            
            enum CodingKeys: CodingKey {
              case results
            }
          }
          struct PokemonResult: Codable {
            let name: String
            let url: URL
          }
          
          struct PokemonDetails: Codable {
            let name: String
            let sprites: Sprites
            
            enum CodingKeys: CodingKey {
              case name
              case sprites
            }
          }
          struct Sprites: Codable {
            let front_default: URL
            
            enum CodingKeys: CodingKey {
              case front_default
            }
          }
          
          let pokemonURLS = try await JSONDecoder().decode(
            Response.self,
            from: URLSession.shared.data(from: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!).0
          )
            .results
            .map(\.url)
          
          for url in pokemonURLS {
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

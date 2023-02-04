import Foundation

extension PokemonClientAsync {
  
  /**
   This version connects to the pokeAPI:
   <https://pokeapi.co/>
   
   All the Pokémon data you'll ever need in one place,
   easily accessible through a modern RESTful API.
   */
  static var live: Self {
    .init(
      fetchPokemonSerial: {
        AsyncStream<Pokemon> { continuation in
          let task = Task {
            NSLog("PokemonClientAsync.fetchPokemonSerial begin")
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!
            guard let data = try? await URLSession.shared.data(from: url),
                  let response = try? JSONDecoder().decode(Response.self, from: data.0)
            else { continuation.finish(); return }
            
            for url in response.results.map(\.url) {
              guard !Task.isCancelled
              else {
                NSLog("PokemonClientAsync.fetchPokemonSerial cancel")
                break
              }
              guard let pokemonDetail = try? await JSONDecoder().decode(
                PokemonDetails.self,
                from: URLSession.shared.data(from: url).0
              )
              else { continue }
              let pokemon = Pokemon(
                id: UUID(),
                name: pokemonDetail.name,
                imageURL: pokemonDetail.sprites.front_default,
                url: url
              )
              NSLog("PokemonClientAsync.fetchPokemonSerial fetching: \(url)")
              continuation.yield(pokemon)
            }
            continuation.finish()
          }
          continuation.onTermination = { _ in
            NSLog("PokemonClientAsync.fetchPokemonSerial terminate")
            task.cancel()
          }
        }
      },
      
      fetchPokemonParallel: {
        AsyncStream { continuation in
          let task = Task {
            NSLog("PokemonClientAsync.fetchPokemonParallel begin")
            let urls = try await JSONDecoder().decode(
              Response.self,
              from: URLSession.shared.data(from: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!).0
            ).results.map(\.url)
            
            await withThrowingTaskGroup(of: Void.self) { group in
              for url in urls {
                group.addTask {
                  let pokemonDetail = try await JSONDecoder().decode(
                    PokemonDetails.self,
                    from: URLSession.shared.data(from: url).0
                  )
                  let pokemon = Pokemon(
                    id: UUID(),
                    name: pokemonDetail.name,
                    imageURL: pokemonDetail.sprites.front_default,
                    url: url
                  )
                  NSLog("PokemonClientAsync.fetchPokemonParallel fetching: \(url)")
                  continuation.yield(pokemon)
                }
              }
            }
            continuation.finish()
          }
          continuation.onTermination = { _ in
            NSLog("PokemonClientAsync.fetchPokemonParallel terminate")
            task.cancel()
          }
        }
      }
    )
  }
}

// MARK: - JSON Parse Types
private extension PokemonClientAsync {
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

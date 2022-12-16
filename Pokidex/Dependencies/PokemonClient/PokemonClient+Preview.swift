import Foundation

extension PokemonClient {
  static var preview: Self {
    .init(fetchPokemon: {
      AsyncStream { continuation in
        Task {
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
          
          for model in models {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC) // Add a delay
            continuation.yield(model)
          }
        }
      }
    })
  }
}


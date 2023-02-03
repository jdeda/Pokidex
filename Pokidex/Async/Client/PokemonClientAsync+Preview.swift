import Foundation

extension PokemonClientAsync {
  static var preview: Self {
    .init(
      fetchPokemonSerial: {
        AsyncStream { continuation in
          Task {
            for model in models {
              try await Task.sleep(nanoseconds: NSEC_PER_SEC) // Add a delay
              continuation.yield(model)
            }
          }
        }
      },
      fetchPokemonParallel: {
        AsyncStream { continuation in
          Task {
            for model in models {
              try await Task.sleep(nanoseconds: NSEC_PER_SEC) // Add a delay
              continuation.yield(model)
            }
          }
        }
      }
    )
  }
}

// MARK: - Data
private let models: [PokemonClientAsync.Pokemon] = [
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

import SwiftUI

class ViewModel: ObservableObject {
  @Published var pokemon = [PokemonModel]()
  var pokemonClient = PokemonClient.liveValue
  
  @MainActor
  func onAppear() async  {
    do {
      self.pokemon = try await pokemonClient.fetchPokemon()
    } catch {
      print(error)
    }
  }
}

struct PokemonClient {
  var fetchPokemon: @Sendable () async throws -> [PokemonModel]
}

extension PokemonClient {
  
  // API: https://pokeapi.co/
  static var liveValue: Self {
    .init(fetchPokemon: {
      try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
      return [
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
      ]
    })
  }
}

extension PokemonClient {
  static var previewValue: Self {
    .init(fetchPokemon: {
      [
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
    })
  }
}
struct PokemonModel: Identifiable {
  let id: UUID
  let name: String
  let imageURL: URL
}

struct ContentView: View {
  @ObservedObject var viewModel = ViewModel()
  
  var body: some View {
    NavigationView {
      List {
        ForEach(viewModel.pokemon) { pokemonModel in
          PokemonView(pokemon: pokemonModel)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Pokemon")
    }
    .onAppear {
      Task {
        await viewModel.onAppear()
      }
    }
  }
}

struct PokemonView: View {
  let pokemon: PokemonModel
  
  var body: some View {
    HStack {
      AsyncImage(url: pokemon.imageURL) { image in
        image
          .resizable()
          .scaledToFit()
      } placeholder: {
        ProgressView()
      }
      .frame(width: 50, height: 50)
      .background(Color(.systemGray6))
      .clipShape(Circle())
      
      Text(pokemon.name)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

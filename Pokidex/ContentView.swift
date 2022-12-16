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
      
      var pokemonDetails = [PokemonDetails]()
      for url in pokemonURLS {
        let pokemonDetail = try await JSONDecoder().decode(
          PokemonDetails.self,
          from: URLSession.shared.data(from: url).0
        )
        pokemonDetails.append(pokemonDetail)
      }
      
      let pokemon = pokemonDetails.map {
        PokemonModel(id: UUID(), name: $0.name, imageURL: $0.sprites.front_default)
      }
      
      print(pokemon)
      return pokemon
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
struct PokemonModel: Identifiable, Codable {
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

import SwiftUI

class ViewModel: ObservableObject {
  @Published var pokemon = [PokemonClient.Pokemon]()
  var pokemonClient: PokemonClient
  
  init(pokemonClient: PokemonClient) {
    self.pokemonClient = pokemonClient
  }
  
  @MainActor
  func onAppear() async  {
    for await pokemon in pokemonClient.fetchPokemon() {
      self.pokemon.append(pokemon)
    }
  }
}

struct ContentView: View {
  @ObservedObject var viewModel: ViewModel
  
  var body: some View {
    NavigationView {
      List {
        ForEach(viewModel.pokemon) { pokemon in
          PokemonView(pokemon: pokemon)
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
  let pokemon: PokemonClient.Pokemon
  
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
      
      Text(pokemon.name.capitalized)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(viewModel: .init(pokemonClient: .previewValue))
  }
}

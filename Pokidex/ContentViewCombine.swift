import SwiftUI
import Combine

class ViewModelCombine: ObservableObject {
  @Published var pokemon = [PokemonClientCombine.Pokemon]()
  var pokemonClient: PokemonClientCombine = .live
  var cancellables = Set<AnyCancellable>()
  
  init(pokemonClient: PokemonClientCombine) {
    self.pokemonClient = pokemonClient
  }
  
  func onAppear()  {
    self.pokemonClient.fetchPokemon
      .receive(on: DispatchQueue.main)
      .sink { self.pokemon.append($0) }
      .store(in: &cancellables)
  }
}


struct ContentViewCombine: View {
  @ObservedObject var viewModel: ViewModelCombine
  
  var body: some View {
    NavigationView {
      List {
        ForEach(viewModel.pokemon) { pokemon in
          PokemonViewCombine(pokemon: pokemon)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Pokemon")
    }
    .onAppear {
      viewModel.onAppear()
    }
  }
}

struct PokemonViewCombine: View {
  let pokemon: PokemonClientCombine.Pokemon
  
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

struct ContentViewCombine_Previews: PreviewProvider {
  static var previews: some View {
    ContentViewCombine(viewModel: .init(pokemonClient: .preview))
  }
}

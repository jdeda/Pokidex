import SwiftUI
import Combine

class ViewModel: ObservableObject {
  @Published var pokemon = [PokemonClient.Pokemon]()
  @Published var message = "Nice"
  var pokemonClient: PokemonClient
  
  init(pokemonClient: PokemonClient) {
    self.pokemonClient = pokemonClient
  }
  
  @MainActor
  func onAppear() async  {
    let start = Date()
    defer {
      debugPrint("onAppear", "finished in", Date().timeIntervalSince(start))
    }
    for await pokemon in pokemonClient.fetchPokemon() {
      debugPrint("onAppear", "finished in", pokemon)
      self.pokemon.append(pokemon)
    }
    self.message = "onAppear finished in \(Date().timeIntervalSince(start)))"
  }
  
  @MainActor
  func onAppearConcurrently() async  {
    let start = Date()
    defer {
      debugPrint("onAppearConcurrently", "finished in", Date().timeIntervalSince(start))
    }
    for await pokemon in pokemonClient.fetchPokemonConcurrently() {
      self.pokemon.append(pokemon)
    }
    self.message = "onAppearConcurrently finished in \(Date().timeIntervalSince(start)))"
  }
}

struct ContentViewMVVMAsync: View {
  @ObservedObject var viewModel: ViewModel
  
  var body: some View {
    NavigationView {
      VStack {
        Text("\(viewModel.pokemon.count)")
        Text("\(viewModel.message)")
        List {
          ForEach(viewModel.pokemon, content: PokemonView.init)
        }
        .listStyle(.plain)
      }
    }
    .onAppear {
      Task {
        await viewModel.onAppearConcurrently()
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

struct ContentViewMVVMAsync_Previews: PreviewProvider {
  static var previews: some View {
    ContentViewMVVMAsync(viewModel: .init(pokemonClient: .previewValue))
  }
}

import SwiftUI
import Combine

// MARK: - ViewModel
final class AsyncViewModel: ObservableObject {
  @Published var pokemon = [PokemonClientAsync.Pokemon]()
  var pokemonClient: PokemonClientAsync
  
  init(pokemonClient: PokemonClientAsync) {
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
  }
}

// MARK: - View
struct AsyncView: View {
  @ObservedObject var viewModel: AsyncViewModel
  
  var body: some View {
    List {
      ForEach(viewModel.pokemon, content: PokemonView.init)
    }
    .listStyle(.plain)
    .toolbar {
      ToolbarItemGroup.init(placement: .navigationBarTrailing) {
          Button {
            
          } label: {
            Image(systemName: "clock.arrow.circlepath")
              .help("Fetch serially")
          }
          Button {

          } label: {
            Image(systemName: "clock.arrow.2.circlepath")
              .help("Fetch parallelly")
          }
      }
    }
    .onAppear { Task {
      await viewModel.onAppearConcurrently()
    }}
  }
}

// MARK: - Helper Views
fileprivate struct PokemonView: View {
  let pokemon: PokemonClientAsync.Pokemon
  
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

// MARK: - Previews
struct AsyncView_Previews: PreviewProvider {
  static var previews: some View {
    AsyncView(viewModel: .init(pokemonClient: .previewValue))
  }
}

import SwiftUI
import Combine

// MARK: - ViewModel
final class CombineViewModel: ObservableObject {
  @Published var pokemon = [PokemonClientCombine.Pokemon]()
  var pokemonClient: PokemonClientCombine = .live
  var cancellables = Set<AnyCancellable>()
  
  init(pokemonClient: PokemonClientCombine) {
    self.pokemonClient = pokemonClient
  }
  
  func onAppear()  {
    let start = Date()
    self.pokemonClient.fetchPokemon
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        debugPrint("onAppear", "finished in", Date().timeIntervalSince(start))
      }, receiveValue: { pokemon in
        self.pokemon.append(pokemon)
      })
      .store(in: &cancellables)
  }
  
  func onAppearConcurrently()  {
    let start = Date()
    self.pokemonClient.fetchPokemonConcurrently
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        debugPrint("onAppear", "finished in", Date().timeIntervalSince(start))
      }, receiveValue: { pokemon in
        self.pokemon.append(pokemon)
      })
      .store(in: &cancellables)
  }
}

// MARK: - View
struct CombineView: View {
  @ObservedObject var viewModel: CombineViewModel
  
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
    .onAppear {
      viewModel.onAppearConcurrently()
    }
  }
}

// MARK: - Helper Views
fileprivate struct PokemonView: View {
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

// MARK: - Previews
struct CombineView_Previews: PreviewProvider {
  static var previews: some View {
    CombineView(viewModel: .init(pokemonClient: .preview))
  }
}

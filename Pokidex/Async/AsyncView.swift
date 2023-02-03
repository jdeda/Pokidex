import SwiftUI
import SwiftUINavigation

// MARK: - ViewModel
final class AsyncViewModel: ObservableObject {
  @Published var pokemon = [PokemonClientAsync.Pokemon]()
  let pokemonClient: PokemonClientAsync
  @Published var fetchMessage: String
  
  init(pokemonClient: PokemonClientAsync) {
    self.pokemonClient = pokemonClient
    fetchMessage = ""
  }
  
  @MainActor
  func onAppear() async  {
    let start = Date()
    defer {
      self.fetchMessage = "fetched \(self.pokemon.count) pokemon in \(start.elapsedTime)"
    }
    for await pokemon in pokemonClient.fetchPokemonSerial() {
      self.pokemon.append(pokemon)
      self.fetchMessage = "fetched \(self.pokemon.count) pokemon"
    }
  }
  
  @MainActor
  func onAppearParallel() async  {
    let start = Date()
    defer {
      self.fetchMessage = "fetched \(self.pokemon.count) pokemon in \(start.elapsedTime)"
    }
    for await pokemon in pokemonClient.fetchPokemonParallel() {
      self.pokemon.append(pokemon)
      self.fetchMessage = "fetched \(self.pokemon.count) pokemon"
    }
  }
  
  @MainActor
  func fetchSerialButtonTapped() async {
    pokemon = []
    await onAppear()
  }
  
  @MainActor
  func fetchParallelButtonTapped() async {
    pokemon = []
    await onAppearParallel()
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
//            await viewModel.fetchSerialButtonTapped()
          } label: {
            Image(systemName: "clock.arrow.circlepath")
              .help("Fetch serially")
          }
          Button {
//            await viewModel.fetchParallelButtonTapped()
          } label: {
            Image(systemName: "clock.arrow.2.circlepath")
              .help("Fetch parallelly")
          }
      }
      ToolbarItemGroup.init(placement: .bottomBar) {
        Text(viewModel.fetchMessage)
          .font(.caption)
      }
    }
    .task {
      await viewModel.onAppearParallel()
    }
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

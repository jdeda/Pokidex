import SwiftUI
import Combine

// MARK: - ViewModel
final class CombineViewModel: ObservableObject {
  @Published var pokemon = [PokemonClientCombine.Pokemon]()
  @Published var fetchMessage: String
  
  let pokemonClient: PokemonClientCombine
  var cancellables = Set<AnyCancellable>()
  
  init(pokemonClient: PokemonClientCombine) {
    self.pokemonClient = pokemonClient
    self.fetchMessage = "0 pokemon"
  }
  
  // Race conditions?
  // circular reference
  private func fetchSerial()  {
    let start = Date()
    self.pokemonClient.fetchPokemonSerial
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        self.fetchMessage = "fetched \(self.pokemon.count) pokemon in \(start.elapsedTime)"
      }, receiveValue: { [weak self] pokemon in
        guard let self = self else { return }
        self.pokemon.append(pokemon)
        self.fetchMessage = "\(self.pokemon.count) pokemon"
      })
      .store(in: &cancellables)
  }
  
  private func fetchParallel()  {
    let start = Date()
    self.pokemonClient.fetchPokemonParallel
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        self.fetchMessage = "fetched \(self.pokemon.count) pokemon in \(start.elapsedTime)"
      }, receiveValue: { [weak self] pokemon in
        guard let self else { return }
        self.pokemon.append(pokemon)
        self.fetchMessage = "\(self.pokemon.count) pokemon"
      })
      .store(in: &cancellables)
  }
  
  func onAppear() {
    fetchSerial()
  }
  
  func fetchSerialButtonTapped() {
    pokemon = []
    fetchMessage = "0 pokemon"
    cancellables.removeAll()
    fetchSerial()
  }
  
  func fetchParallelButtonTapped() {
    pokemon = []
    fetchMessage = "0 pokemon"
    cancellables.removeAll()
    fetchParallel()
  }
  
  func resetButtonTapped() {
    pokemon = []
    fetchMessage = "0 pokemon"
    cancellables.removeAll()
  }
  
  func onDisappear() {
    cancellables.removeAll()
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
          viewModel.fetchSerialButtonTapped()
        } label: {
          Image(systemName: "clock.arrow.circlepath")
            .help("Fetch serially")
        }
        Button {
          viewModel.fetchParallelButtonTapped()
        } label: {
          Image(systemName: "clock.arrow.2.circlepath")
            .help("Fetch parallelly")
        }
        Button {
          viewModel.resetButtonTapped()
        } label: {
          Image(systemName: "xmark.circle")
            .help("Reset data")
        }
      }
      ToolbarItemGroup.init(placement: .bottomBar) {
        Text(viewModel.fetchMessage)
          .font(.caption)
      }
    }
    .onAppear(perform: viewModel.onAppear)
    .onDisappear(perform: viewModel.onDisappear)
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

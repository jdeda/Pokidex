import Foundation
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
  
  private func fetchSerial()  {
    let start = Date()
    self.pokemonClient.fetchPokemonSerial
      .receive(on: DispatchQueue.main)
      .handleEvents(
        receiveSubscription: { _ in
          NSLog("PokemonClientCombine.fetchPokemonSerial begin")
        },
        receiveOutput: { pokemon in
          NSLog("PokemonClientCombine.fetchPokemonSerial fetching: \(pokemon.url)")
        },
        receiveCompletion: { _ in
          NSLog("PokemonClientCombine.fetchPokemonSerial terminate")

        },
        receiveCancel: { 
          NSLog("PokemonClientCombine.fetchPokemonSerial cancel")
        }
      )
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
      .handleEvents(
        receiveSubscription: { _ in
          NSLog("PokemonClientCombine.fetchPokemonParallel begin")
        },
        receiveOutput: { pokemon in
          NSLog("PokemonClientCombine.fetchPokemonParallel fetching: \(pokemon.url)")
        },
        receiveCompletion: { _ in
          NSLog("PokemonClientCombine.fetchPokemonParallel terminate")
        },
        receiveCancel: {
          NSLog("PokemonClientCombine.fetchPokemonSerial cancel")
        }
      )
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
  
  func onAppear() {
    fetchSerial()
  }
  
  func onDisappear() {
    cancellables.removeAll()
  }
}

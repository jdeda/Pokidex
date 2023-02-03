import Foundation

//struct TaskCancellable<V, E: Error>: Identifiable, Hashable  {
//  let id: UUID
//  let task: Task<V, E>
//}

// MARK: - ViewModel
final class AsyncViewModel: ObservableObject {
  @Published var pokemon = [PokemonClientAsync.Pokemon]()
  @Published var fetchMessage: String
  private var currentTask: Task<Void, Never>? = nil
  
  let pokemonClient: PokemonClientAsync
  
  
  init(pokemonClient: PokemonClientAsync) {
    self.pokemonClient = pokemonClient
    fetchMessage = ""
  }
  
  @MainActor
  private func fetchSerial() async {
    currentTask = Task {
      let start = Date()
      defer {
        if !Task.isCancelled {
          self.fetchMessage = "fetched \(self.pokemon.count) pokemon in \(start.elapsedTime)"
        }
      }
      for await pokemon in pokemonClient.fetchPokemonSerial() {
        if Task.isCancelled { return }
        self.pokemon.append(pokemon)
        self.fetchMessage = "fetched \(self.pokemon.count) pokemon"
      }
    }
  }
  
  @MainActor
  private func fetchParallel() async {
    currentTask = Task {
      let start = Date()
      defer {
        if !Task.isCancelled {
          self.fetchMessage = "fetched \(self.pokemon.count) pokemon in \(start.elapsedTime)"
        }
      }
      for await pokemon in pokemonClient.fetchPokemonParallel() {
        if Task.isCancelled { break }
        self.pokemon.append(pokemon)
        self.fetchMessage = "fetched \(self.pokemon.count) pokemon"
      }
    }
  }
  
  private func reset() {
    pokemon = []
    fetchMessage = "0 pokemon"
    cancelCurrentTask()
  }
  
  @MainActor
  func fetchSerialButtonTapped() async {
    reset()
    currentTask = Task {
      if Task.isCancelled { return }
      await fetchSerial()
    }
  }
  
  @MainActor
  func fetchParallelButtonTapped() async {
    reset()
    currentTask = Task {
      if Task.isCancelled { return }
      await fetchParallel()
    }
  }
  
  func resetButtonTapped() {
    reset()
  }
  
  private func cancelCurrentTask() {
    guard let unwrappedTask = currentTask else { return }
    unwrappedTask.cancel()
    currentTask = nil
  }
  
  @MainActor
  func onAppear() async {
    await fetchSerial()
  }
  
  func onDisappear() {
    cancelCurrentTask()
  }
}

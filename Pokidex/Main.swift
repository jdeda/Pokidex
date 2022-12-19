import SwiftUI

@main
struct Main: App {
  var body: some Scene {
    WindowGroup {
//      ContentView(viewModel: .init(pokemonClient: .liveValue))
      ContentViewCombine(viewModel: .init(pokemonClient: .live))
    }
  }
}

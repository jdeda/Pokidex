import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationView {
        Form {
          ForEach(ContentChoice.allCases, id: \.self) { choice in
            NavigationLink {
              switch choice {
              case .MVVMCombine:
                ContentViewMVVMCombine(viewModel: .init(pokemonClient: .live))
                  .navigationTitle("Pokemon")
              case .MVVMAsync:
                ContentViewMVVMAsync(viewModel: .init(pokemonClient: .live))
                  .navigationTitle("Pokemon")
              case .TCA:
                ContentViewMVVMAsync(viewModel: .init(pokemonClient: .live))
                  .navigationTitle("Pokemon")
              }
            } label: {
              HStack {
                Image(systemName: "bolt.fill")
                Text("\(choice.string)")
              }
              .padding()
            }
          }
        }
      .navigationBarTitle("Implementation")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

enum ContentChoice: CaseIterable {
  case MVVMCombine
  case MVVMAsync
  case TCA
}

extension ContentChoice {
  var string: String {
    switch self {
    case .MVVMCombine:
      return "MVVM Combine"
    case .MVVMAsync:
      return "MVVM Async"
    case .TCA:
      return "TCA"
    }
  }
}

import SwiftUI
import SwiftUINavigation

final class ContentViewModel: ObservableObject {
  @Published var destination: Destination? = nil
  
  func rowTapped(_ choice: ContentChoice) {
    switch choice {
    case .MVVMCombine:
      destination = .combine(.init(pokemonClient: .live))
    case .MVVMAsync:
      destination = .async(.init(pokemonClient: .live))
    }
  }
  
  enum Destination {
    case combine(ViewModelCombine)
    case async(ViewModelAsync)
  }
}
struct ContentView: View {
  @ObservedObject var viewModel: ContentViewModel = .init()
  var body: some View {
    NavigationStack {
        Form {
          ForEach(ContentChoice.allCases, id: \.self) { choice in
            Button {
              viewModel.rowTapped(choice)
            } label: {
              HStack {
                Image(systemName: "bolt.fill")
                Text("\(choice.string)")
              }
            }
            .padding()
          }
        }
        .navigationDestination(
          unwrapping: $viewModel.destination,
          case: /ContentViewModel.Destination.combine
        ) { $combineViewModel in
          ContentViewMVVMCombine(viewModel: combineViewModel)
        }
        .navigationDestination(
          unwrapping: $viewModel.destination,
          case: /ContentViewModel.Destination.async
        ) { $asyncViewModel in
          ContentViewMVVMAsync(viewModel: asyncViewModel)
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
}

extension ContentChoice {
  var string: String {
    switch self {
    case .MVVMCombine:
      return "MVVM Combine"
    case .MVVMAsync:
      return "MVVM Async"
    }
  }
}

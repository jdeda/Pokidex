import SwiftUI
import SwiftUINavigation

// MARK: - View
struct AppView: View {
  @ObservedObject var viewModel: AppViewModel
  var body: some View {
    NavigationStack {
      Form {
        ForEach(AppViewModel.ContentChoice.allCases, id: \.self) { choice in
          Button { viewModel.rowTapped(choice) } label: {
            HStack {
              Image(systemName: "bolt.fill")
              Text("\(choice.string)")
            }
          }
          .padding(5)
        }
      }
      .navigationDestination(
        unwrapping: $viewModel.destination,
        case: /AppViewModel.Destination.combine
      ) { $combineViewModel in
        CombineView(viewModel: combineViewModel)
          .navigationTitle(AppViewModel.ContentChoice.combine.string)
      }
      .navigationDestination(
        unwrapping: $viewModel.destination,
        case: /AppViewModel.Destination.async
      ) { $asyncViewModel in
        AsyncView(viewModel: asyncViewModel)
          .navigationTitle(AppViewModel.ContentChoice.async.string)
      }
      .navigationBarTitle("Implementation")
    }
  }
}

// MARK: - Previews
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(viewModel: .init())
  }
}

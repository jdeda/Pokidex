import SwiftUI

// MARK: - ViewModel
final class AppViewModel: ObservableObject {
  @Published var destination: Destination? = nil
  
  func rowTapped(_ choice: ContentChoice) {
    switch choice {
    case .combine:
      destination = .combine(.init(pokemonClient: .live))
    case .async:
      destination = .async(.init(pokemonClient: .live))
    }
  }
}

// MARK: - ViewModel.Destination
extension AppViewModel {
  enum Destination {
    case combine(CombineViewModel)
    case async(AsyncViewModel)
    
  }
}

// MARK: - ViewModel.ContentChoice
extension AppViewModel {
  enum ContentChoice: CaseIterable {
    case combine
    case async
    
    var string: String {
      switch self {
      case .combine:
        return "Combine"
      case .async:
        return "Async"
      }
    }
  }
}


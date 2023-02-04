import SwiftUI

// MARK: - ViewModel
final class AppViewModel: ObservableObject {
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
    case combine(CombineViewModel)
    case async(AsyncViewModel)
  }
  
  enum ContentChoice: CaseIterable {
    case MVVMCombine
    case MVVMAsync
    
    var string: String {
      switch self {
      case .MVVMCombine:
        return "Combine"
      case .MVVMAsync:
        return "Async"
      }
    }
  }
}


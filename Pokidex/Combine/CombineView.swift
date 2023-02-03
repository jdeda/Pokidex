import SwiftUI
import Combine

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

import SwiftUI

struct PokemonModel: Identifiable {
  let id: UUID
  let name: String
  let imageURL: URL
}

struct ContentView: View {
  let pokemon: [PokemonModel]
  
  var body: some View {
    NavigationView {
      List {
        ForEach(pokemon) { pokemonModel in
          PokemonView(pokemon: pokemonModel)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Pokemon")
    }
  }
}

struct PokemonView: View {
  let pokemon: PokemonModel
  
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
      
      Text(pokemon.name)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(pokemon: [
      .init(
        id: UUID(),
        name: "bulbasaur",
        imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!
      ),
      .init(
        id: UUID(),
        name: "ivysaur",
        imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png")!
      ),
      .init(
        id: UUID(),
        name: "venusaur",
        imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png")!
      ),
    ])
    //      .preferredColorScheme(.dark)
  }
}

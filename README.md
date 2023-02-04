# ⚡Pokidex

<img src="https://github.com/jdeda/Pokidex/blob/main/Assets/PokidexBanner.png" alt="drawing" width="650"/>

## Welcome to Pokidex!
Pokidex is a simple native iOS app for demonstrating Swift 5.5's brand new structured concurrency. The app essentially displays a list of pokemon which is streamed into the system, fetching data serially or in-parallel. This feature is implemented in two ways, in Combine or Swift's new concurrency system. Both implementations use MVVM for state management. Pokemon data is fetched from the [PokeAPI](https://pokeapi.co/).

## Table of Contents
  - [Welcome to Pokidex!](#welcome-to-pokidex)
  - [Table of Contents](#table-of-contents)
  - [JSON to Swift](#json-to-swift)
  - [Combine](#combine)
  - [Async](#async)
  - [More](#more)

<hr>

## JSON to Swift
The very first step in getting our data is converting JSON into Swift types. We want our end result to look like this:
```swift
  struct Pokemon: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageURL: URL
    let url: URL
  }
```

To achieve this, we must first take a look at the structure of the JSON data, then model some intermediary types specifically for JSON accordingly. Fetching the first 100 elements of data: `https://pokeapi.co/api/v2/pokemon?limit=100&offset=0`, we have following JSON structure:
```json
{
  "count": 1279,
  "next": "https://pokeapi.co/api/v2/pokemon?offset=10&limit=10",
  "previous": null,
  "results": [
    {
      "name": "bulbasaur",
      "url": "https://pokeapi.co/api/v2/pokemon/1/"
    },
    ...
  ]
}
```
We are really only interested in the `url` property in each element of the `results` property. We can model a Swift type for that: 
```swift
struct Response: Codable {
    let results: [EachResult]
    enum CodingKeys: CodingKey {
      case results
    }
  }
  struct EachResult: Codable {
    let url: URL
    enum CodingKeys: CodingKey {
      case url
    }
  }
```
Once we retrieve the data from the original URL, we can parse that data into the `Response` and extract our data as `[URL]`:
```swift
let response = try JSONDecoder().decode(Response.self, from: data)
let urls = response.results.map(\.url)
```
Each URL contains the data for a specific pokemon, with the following JSON structure: 
```json
{
    "abilities": […],
    "base_experience": 64,
    "forms": […],
    "game_indices": […],
    "height": 7,
    "held_items":	[],
    "id": 1,
    "is_default":	 true,
    "location_area_encounters": "https://pokeapi.co/api/v2/pokemon/1/encounters",
    "moves":	[…],
    "name":	"bulbasaur",
    "order": 1,
    "past_types":	[],
    "species":	{…},
    "sprites":	{
        ...
    },
    "stats":	[…],
    "types":	[…],
    "weight": 69
}
```
This object actually has an enormous amount of data, but we only care for a few things in this app, so it'd look more like this:
```json
{
    "name":	"bulbasaur",
    "sprites":	{
            "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"
    },
}
```
Then, we model another Swift type for this:
```swift
  struct PokemonDetails: Codable {
    let name: String
    let sprites: PokemonSprites
    
    enum CodingKeys: CodingKey {
      case name
      case sprites
    }
  }
  struct PokemonSprites: Codable {
    let front_default: URL
    
    enum CodingKeys: CodingKey {
      case front_default
    }
  }
```
And finally we can convert each URL for a pokemon into a Pokemon:
```swift
  let pd = try JSONDecoder().decode(PokemonDetails.self, from: data)
  let pokemon = Pokemon(id: UUID(), name: pd.name, imageURL: pd.sprites.front_default, url: url)
```

For both implementations, we end up with the following types:
```swift
// MARK: - JSON Parse Types
private extension PokemonClientCombine {
  struct Response: Codable {
    let results: [EachResult]
    
    enum CodingKeys: CodingKey {
      case results
    }
  }
  struct EachResult: Codable {
    let url: URL
    
    enum CodingKeys: CodingKey {
      case url
    }
  }
  struct PokemonDetails: Codable {
    let name: String
    let sprites: PokemonSprites
    
    enum CodingKeys: CodingKey {
      case name
      case sprites
    }
  }
  struct PokemonSprites: Codable {
    let front_default: URL
    
    enum CodingKeys: CodingKey {
      case front_default
    }
  }
}
```

<hr>

## Combine
We'd like to stream the data in two ways: serially and in-parallel. Using our defined types and the `URLSession.shared.dataTaskPublisher`, we can build a publisher to fetch our data:
```swift
URLSession.shared.dataTaskPublisher(for: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!)
        .map { data, response -> [URL] in
          guard
            let responseHTTP = response as? HTTPURLResponse,
            responseHTTP.statusCode == 200
          else { return [] }
          do {
            let response = try JSONDecoder().decode(Response.self, from: data)
            return response.results.map(\.url)
          } catch {
            return []
          }
        }
        .replaceError(with: [])
        .flatMap(\.publisher)
        .flatMap(maxPublishers: .max(1), URLSession.shared.dataTaskPublisher(for:))
        .compactMap { data, response -> Pokemon? in
          guard
            let responseHTTP = response as? HTTPURLResponse,
            responseHTTP.statusCode == 200,
            let url = response.url
          else { return nil }
          do {
            let pd = try JSONDecoder().decode(PokemonDetails.self, from: data)
            return .init(id: UUID(), name: pd.name, imageURL: pd.sprites.front_default, url: url)
          } catch {
            return nil
          }
        }
        .replaceError(with: Pokemon(id: UUID(), name: "", imageURL: URL(string: "foo")!, url: URL(string: "foo")!))
        .eraseToAnyPublisher()
```
Here, we are fetching our data serially, ignoring errors, and replacing with either empty or dummy data. If we want of fetch our data in parallel, it is as simple as changing one of our flatmaps from this:
```swift
.flatMap(maxPublishers: .max(1), URLSession.shared.dataTaskPublisher(for:))
```
to this:
```swift
.flatMap(URLSession.shared.dataTaskPublisher(for:))
```
This is pretty powerful stuff, and attests to the beauty of Combine's use of higher order functions. However, what are things like in the async world?

<hr>

## Async
To acheive streaming using Swift 5.5's concurrency tools, we can use `AsyncStream`. Starting with fetching serially:
```swift
AsyncStream<Pokemon> { continuation in
  let task = Task {
    let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!
    guard let data = try? await URLSession.shared.data(from: url),
          let response = try? JSONDecoder().decode(Response.self, from: data.0)
    else { continuation.finish(); return }
    
    for url in response.results.map(\.url) {
      guard !Task.isCancelled
      else { break }
      guard let pokemonDetail = try? await JSONDecoder().decode(
        PokemonDetails.self,
        from: URLSession.shared.data(from: url).0
      )
      else { continue }
      let pokemon = Pokemon(
        id: UUID(),
        name: pokemonDetail.name,
        imageURL: pokemonDetail.sprites.front_default,
        url: url
      )
      continuation.yield(pokemon)
    }
    continuation.finish()
  }
  continuation.onTermination = { _ in
    task.cancel()
  }
}
```
Here we are handling cancellation, so that in the event we want to cancel our stream, the stream ends and we don't leak any resources. How this works is an indepth discussion I'd rather not cover here, but nonetheless a very good one. Moving on, it'd be nice to fetch the data in-parallel, and it's as easy as opening up a task group using `withTaskGroup`:
```swift
AsyncStream { continuation in
  let task = Task {
    let urls = try await JSONDecoder().decode(
      Response.self,
      from: URLSession.shared.data(from: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!).0
    ).results.map(\.url)
    
    await withThrowingTaskGroup(of: Void.self) { group in // Add this
      for url in urls {
        group.addTask {
          let pokemonDetail = try await JSONDecoder().decode(
            PokemonDetails.self,
            from: URLSession.shared.data(from: url).0
          )
          let pokemon = Pokemon(
            id: UUID(),
            name: pokemonDetail.name,
            imageURL: pokemonDetail.sprites.front_default,
            url: url
          )
          continuation.yield(pokemon)
        }
      }
    }
    continuation.finish()
  }
  continuation.onTermination = { _ in
    task.cancel()
  }
}
```
Remember that tasks require cooperative cancellation, thus when we fetched the work serially, we had to inject some logic to handle that, by using the `Task.isCancelled` property. Here, our work is done in a task group, which will automatically be cancelled if its parent is cancelled.

<hr>

## More
There is so much that could be discussed with these `Combine` and Swift's 5.5 concurrency tools. This app just scratches the surfaces, but aims to implement and understand good practices for using both of these tools. Check out the app to see much more!

# Veil

Flickr API based image displaying app.

All the code has been written by hand, mostly without checking any external resources. No code has been copied. Even though I wrote protocols like `StoryboardInstantiable` and `Identifiable` before, I wrote them again. Wherever I thought as comments would be useful for the future reader, I left them (mostly inside `ImageCacher` class which makes use of 2 `DispatchQueue`s).

## Overview
* **Rx** - The app was first written without any dependencies. Because we have quite some event-based logic - requests, user-events, caching, I decided to use a reactive library. This goes hand in hand with me wanting to try [Binder](https://github.com/DeclarativeHub/TheBinderArchitecture) architecture. In the next paragraph I provided a link to the project before Rx. I know that Rx is a big commitment to make, but I think small quirks like `searchBar.text.debounce`, easy bindings between cells and models and the ViewModel make it shine.
* **Architecture** - In the [beginning](https://github.com/S2dentik/Veil/tree/aae2f10b4ba2d8722a9cabb5e181c52c653a93bf) I used MVP. Then, I decided to give [Binder](https://github.com/DeclarativeHub/TheBinderArchitecture) a shot. As I then realized is that Binder isn't great for testing and switched to MVVM, except model also binds itself to the view. This is done because binding still contains quite a bit of logic that I wanted to test, and didn't want to do it in an UIKit-based class.
* **AppEnvironment** - We have a God object called `AppEnvironment`. All objects pinging into the outside world like `FileManager` and `URLSession` are stored there. I personally prefer this approach over injecting these dependencies into every object that is going to use them, since they are very widely used. It is used for mocking all these external dependencies in a much easier way.
* **Dependency injection** - For small objects like `Fetcher` that are only used by an object, I usually simply inject them, rather than make them globally available to everyone. This can be seen in the `ViewModel`.
* **IB** - Usually I like to have my layout in the XIBs(for cells and other views) / Storyboards(for view controllers), and all of the other UI related setup like setting a font or color in code. Here, to save time, I set some flags using IB.

## // TO-DOs
* Normally I would have used a simple plist for keeping the list of downloaded image IDs, or just read contents of the directory once into an array, then update.
* The app would really benefit from a nicer layout based on image size. Even something as simple as scaling the cell height based on image size would make the app look much better.
* I couldn't think of an easy way to provide dummy cells (before the image loads). For now it just displays a light gray background.
* Mocks have a lot of boilerplate code. I once implemented two classes: `FuncCheck` and `ClosureStub`, but they would require a lot of code to implement, so I used plain primitives for now.
* The app requires more tests. I wrote the code as testable as I could, and provided a strong foundation and some tests of how I would proceed with testing - both sync and async tests. Everything is testable, from small services and helpers to the view models, everything except the view controller. For that I would have to write some snapshot tests, but I don't think it's critical now.

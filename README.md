# Veil

Flickr API based image displaying app.

All the code has been written by hand, mostly without checking any external resources. No code has been copied. Even though I wrote protocols like `StoryboardInstantiable` and `Identifiable` before, I wrote them again. Wherever I thought as comments would be useful for the future reader, I left them (mostly inside `ImageCacher` class which makes use of 2 `DispatchQueue`s).

## Overview
* **Architecture** - The architecture is very simple. I first started with a VIP, but then I saw it as an overkill for a simple screen and moved the interactor logic into the presenter.
* **AppEnvironment** - We have a God object called `AppEnvironment`. All objects pinging into the outside world like `FileManager` and `URLSession` are stored there. I personally prefer this approach over injecting these dependencies into every object that is going to use them, since they are very widely used. It is used for mocking all these external dependencies in a much easier way.
* **Dependency injection** - For small objects like `Fetcher` that are only used by an object, I usually simply inject them, rather than make them globally available to everyone. This can be seen in the `Presenter`.
* **Errors** - Rather than silently fail, I created errors wherever I thought appropriate, and displayed them to the user.
* **IB** - Usually I like to have my layout in the XIBs(for cells and other views) / Storyboards(for view controllers), and all of the other UI related setup like setting a font or color in code. Here, to save time, I set some flags using IB.

## // TO-DOs
* Normally I would have used a simple plist for keeping the list of downloaded image IDs, or just read contents of the directory once into an array, then update.
* The app would really benefit from a nicer layout based on image size. Even something as simple as scaling the cell height based on image size would make the app look much better.
* It would be nice if the code related to networking wouldn't be inside the cell. The easiest thing would be provide the cell with a completion closure in form `(UIImage) -> Void`. The problem is that the class responsible for this would then have to store ongoing tasks for all existing cells, and cancel them when needed. This is failproof and potentially buggy, and needs thorough testing.
* It would be nice to move the logic regarding the loading indicator (which stays present for queries with no images) into the data source which in this case is the presenter.
* I couldn't think of an easy way to provide dummy cells (before the image loads). For now it just displays a light gray background.
* Mocks have a lot of boilerplate code. I once implemented two classes: `FuncCheck` and `ClosureStub`, but they would require a lot of code to implement now, so I used plain primitives for now.
* The app obviously requires more tests. I wrote the code as testable as I could, and provided a strong foundation and some tests of how I would proceed with testing - both sync and async tests. Everything is testable, from small services and helpers to the presenters, everything except the view controller. For that I would have to write some snapshot tests, but since I cannot use any third-party libraries, it would take too much time to implement.

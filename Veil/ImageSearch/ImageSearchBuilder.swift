enum ImageSearchBuilder {
    static func build() -> ImageSearchViewController {
        let view = ImageSearchViewController.instantiate()
        let model = ImageSearchViewModel(services: .init(history: SearchHistory(),
                                                         fetcher: FlickrImageFetcher(),
                                                         cacher: ImageCacher()))
        view.bind(to: model)
        model.bind(to: view)

        return view
    }
}

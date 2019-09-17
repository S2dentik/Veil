final class ImageSearchBuilder {
    static func build() -> ImageSearchViewController {
        let vc = ImageSearchViewController.instantiate()
        vc.output = ImageSearchPresenter(view: vc)

        return vc
    }
}

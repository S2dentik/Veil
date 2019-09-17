protocol ImageFetcher {
    func search(_ query: String,
                page: Int,
                completion: @escaping (Result<[Image], ImageSearchError>) -> Void)
    func cancel()
}

enum ImageSearchError: Error {
    case requestError(RequestError)
    case imageInitializationError
    case invalidIndex
    case invalidSearchTerm(String)
    case decodingError(Error)

    var localizedDescription: String {
        switch self {
        case .requestError(let error): return "Request error \(error.localizedDescription)"
        case .imageInitializationError: return "Image initialization error"
        case .invalidIndex: return "Invalid index for requesting image"
        case .decodingError(let error): return "Decoding error \(error.localizedDescription)"
        case .invalidSearchTerm(_): return "Invalid query"
        }
    }
}

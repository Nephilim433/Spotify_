//
//  APICaller.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    private init() { }

    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    enum APIError: Error {
        case failedToGetData
    }
    //MARK: - Category
    public func getCategories(complition: @escaping (Result<[CategoriesItem],Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories?limit=20"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    complition(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                    complition(.success(result.categories.items))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - getCategoryPlaylists
    public func getCategoryPlaylists(category: CategoriesItem,complition: @escaping (Result<[PlaylistItem],Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=20"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    complition(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(CategoryPlaylistResponse.self, from: data)
                    let playlist = result.playlists.items
                    complition(.success(playlist))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Albums
    public func getAlbumsDetails(for album:Album, complition: @escaping (Result<AlbumDetailsResponse,Error>) -> Void) {
        createRequest(with: URL(string:Constants.baseAPIURL + "/albums/\(album.id)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    complition(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    complition(.success(result))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Get Current User Albums
    public func getCurrentUserAlbums(complition: @escaping (Result<[LibraryAlbumsResponseItem],Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    complition(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(LibraryAlbumsResponse.self, from: data)
                    complition(.success(result.items))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - saveAlbum
    public func saveAlbum(album: Album,complition: @escaping (Bool)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/me/albums?ids=\(album.id)"), type: .PUT) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { _, response, error in
                guard error == nil else {
                    complition(false)
                    return
                }
                let code = (response as? HTTPURLResponse)?.statusCode
                complition(code == 200 || code == 201)
            }
            task.resume()
        }
    }
    //MARK: - Playlist
    public func getPlaylistDetails(for playlist:PlaylistItem, complition: @escaping (Result<[PlaylistTrackItem],Error>) -> Void) {
        createRequest(with: URL(string:Constants.baseAPIURL + "/playlists/\(playlist.id)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    complition(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    let filteredResult = result.tracks.items.filter { $0.track.preview_url != nil }
                    complition(.success(filteredResult))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    public func getCurrentUserPlaylists(complition: @escaping (Result<[PlaylistItem],Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/playlists?limit=20"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data,error == nil else {
                    complition(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(LibraryPlaylistsResponse.self, from: data)
                    complition(.success(result.items))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }

    }
    public func createPlaylists(with name: String, complition: @escaping (Bool) -> Void) {
        getCurrentUserProfile { [weak self] result in
            //change it to make it crate playlist with image and description
            switch result {
            case .success(let profile):
                self?.createRequest(with: URL(string: Constants.baseAPIURL+"/users/\(profile.id)/playlists"), type: .POST) { baseRequest in
                    var request = baseRequest
                    let json = ["name":name]

                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data , error == nil else {
                            complition(false)
                            return
                        }
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let response = result as? [String:Any], response["id"] as? String != nil {
                                print("created")
                                complition(true)
                            } else {
                                print("Failed to create")
                                complition(false)
                            }

                        } catch {
                            print(error)
                            complition(false)
                        }
                    }
                    task.resume()
                }
            case .failure(let error):
                print(error)
                complition(false)
            }
        }

    }
    public func addTrackToPlaylists(track: Track, playlist: PlaylistItem, complition: @escaping (Bool) -> Void) {

        createRequest(with: URL(string: Constants.baseAPIURL+"/playlists/\(playlist.id)/tracks"), type: .POST) { baseRequest in
            var request = baseRequest
            let json = [
                "uris": ["spotify:track:\(track.id)"]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    complition(false)
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        print(result)
                        complition(true)
                    } else {
                        complition(false)
                    }

                } catch {
                    print("failed to add track to playlist")
                    print(error)
                }

            }
            task.resume()
        }
    }
    public func removeTrackFromPlaylists(track: Track, playlist: PlaylistItem, complition: @escaping (Bool) -> Void) {

        createRequest(with: URL(string: Constants.baseAPIURL+"/playlists/\(playlist.id)/tracks"), type: .DELETE) { baseRequest in
            var request = baseRequest
            let json = [
                "tracks": [[
                    "uri":"spotify:track:\(track.id)"
                ]]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    complition(false)
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        print(result)
                        complition(true)
                    } else {
                        complition(false)
                    }
                } catch {
                    print("failed to remove track to playlist")
                    print(error)
                }
            }
            task.resume()
        }
    }
    //MARK: - Get Profile
    public func getCurrentUserProfile(complition: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    complition(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    complition(.success(result))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - GetNEW Releases
    public func getNewReleases(complition: @escaping ((Result<NewReleasesResponse,Error>)) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    complition(.success(result))

                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Get Featured Playlists
    public func getFeaturedPlaylist(complition: @escaping ((Result<FeaturedPlaylistResponse,Error>)) -> Void) {
        //don't know why but this bugged ,
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=20"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else { return }
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                    complition(.success(result))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Recommendations (Tracks)
    public func getRecommendations(genres: Set<String>, complition: @escaping ((Result<[Track],Error>)) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else { return }
                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    let filteredResult = result.tracks.filter { $0.preview_url != nil }
                    complition(.success(filteredResult))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Recommendations (genras)
    public func getRecommendedGanres(complition: @escaping ((Result<RecommendedGenres,Error>)) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else { return }
                do {
                    let result = try JSONDecoder().decode(RecommendedGenres.self, from: data)
                    complition(.success(result))
                } catch  {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Search
    public func search(with query: String, complition: @escaping(Result<[SearchResult],Error>)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { request  in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    complition(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    var searchResults: [SearchResult] = []
                    searchResults.append(contentsOf: result.playlists.items.compactMap({ SearchResult.playlist(model: $0)}))
                    searchResults.append(contentsOf: result.albums.items.compactMap({ SearchResult.album(model: $0)}))
                    searchResults.append(contentsOf: result.tracks.items.compactMap({ SearchResult.track(model: $0)}))
                    searchResults.append(contentsOf: result.artists.items.compactMap({ SearchResult.artist(model: $0)}))
                    complition(.success(searchResults))
                } catch {
                    print(error)
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Private
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    //MARK: - Creating Reequest
    private func createRequest(with url: URL?, type: HTTPMethod, complition: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            complition(request)
        }
    }
}

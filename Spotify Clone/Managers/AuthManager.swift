//
//  AuthManager.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    private var refreshingToken = false

    struct Constants {
        static let appName = "Spøtify"
        //MARK: - DO NOT FORGET TO PUT IN YOUR CLIENT ID AND SECRET
        static let clientID = ""
        static let clientSecret = ""
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"

        private static var scopesArray = ["user-read-private","user-read-email", "playlist-modify-public","playlist-modify-private","playlist-read-collaborative", "playlist-read-private","user-library-read", "user-library-modify","user-follow-read" ]
        static var scopes: String {
            return scopesArray.joined(separator: "%20")
        }

    }

    public var signInURL: URL? {

        let base = "https://accounts.spotify.com/authorize"
//        let scope = "user-read-private"
        let scope = "playlist-modify%20user-read-private%20user-library-read%20user-library-modify"
        let redirectURL = "https://github.com/Nephilim433"

        let str = URL(string:"\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(scope)&redirect_uri=\(redirectURL)&show_dialog=TRUE")
        return str
    }

    var isSignedIn: Bool {
        return accessToken != nil
    }
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else { return false }
        let currentDate = Date()
        let fiveMins = TimeInterval(300)
        return currentDate.addingTimeInterval(fiveMins) >= expirationDate
    }

    func exchangeCodeForToken(code: String, complition: @escaping ((Bool) -> Void)) {
        //get token
        guard let url = URL(string: Constants.tokenAPIURL) else { return }

        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "code", value: code),
                                 URLQueryItem(name: "redirect_uri", value: "https://github.com/Nephilim433"),
                                 URLQueryItem(name: "grant_type", value: "authorization_code")]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base 64")
            complition(false)
            return
        }

        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        //using components as parametrs for url
        request.httpBody = components.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, _, erorr in
            guard let data = data, erorr == nil else {
                complition(false)
                return
            }
            do {
                /*
                 let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                 print("SUCCESS <<<< \(json)")
                 */
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.cacheToken(result: result)
                complition(true)
            } catch  {
                print(error)
                complition(false)
            }
        }
        task.resume()
    }
    private var onRefreshBlocks = [((String) -> Void)]()

    ///Suplies valid token to be used with API Calls
    public func withValidToken(complition: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshBlocks.append(complition)
            return
        }
        if shouldRefreshToken {
            //refresh token
            refreshIfNeeded { success in
                if let token = self.accessToken, success {
                    complition(token)
                }
            }
        } else if let token = accessToken {
            complition(token)
        }
    }

    func refreshIfNeeded(complition: ((Bool) -> Void)?) {
        guard shouldRefreshToken else {
            complition?(true)
            return
        }
        guard let refreshToken = refreshToken else {
            return
        }
        //Refresh the token
        //Copied from initial request for token with code
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        //Controlling the state of refreshing token
        refreshingToken = true

        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"),
                                 URLQueryItem(name: "refresh_token", value: refreshToken)]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base 64")
            complition?(false)
            return
        }

        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        //using components as parametrs for url
        request.httpBody = components.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, _, erorr in
            self.refreshingToken = false

            guard let data = data, erorr == nil else {
                complition?(false)
                return
            }
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("SUCCESSFULLY REFRESHED TOKEN!")
                self.onRefreshBlocks.forEach { $0(result.accessToken)}
                self.onRefreshBlocks.removeAll()
                self.cacheToken(result: result)
                complition?(true)
            } catch  {
                print(error)
                complition?(false)
            }
        }
        task.resume()
    }

    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.set(result.accessToken, forKey: "access_token")
        if let refreshToken = result.refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
        }
        UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(result.expiresIn)), forKey: "expirationDate")
        UserDefaults.standard.set(result.accessToken, forKey: "access_token")
    }
    public func signOut(complition: (Bool)->Void) {
        UserDefaults.standard.set(nil, forKey: "access_token")
        UserDefaults.standard.set(nil, forKey: "refresh_token")
        UserDefaults.standard.set(nil, forKey: "expirationDate")
        complition(true)
    }
}

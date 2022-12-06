//
//  AuthViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import UIKit
import WebKit

class AuthViewController: UIViewController,WKNavigationDelegate {

    public var complitionHandler: ((Bool) -> Void)?

    private let webView: WKWebView = {

        let prefs = WKWebpagePreferences()
        let config = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            prefs.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
            config.preferences.javaScriptEnabled = true
            config.preferences.javaScriptCanOpenWindowsAutomatically = true
        }
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero,
                                configuration: config)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Sign In"
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInURL else {return}
        webView.load(URLRequest(url: url))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        // exchange the "code" for access token
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where:{$0.name == "code"})?.value else { return }
        print("Code = \(code) <<<<<<<<")


        webView.isHidden = true
        //I'm skipping here [weak self]
        AuthManager.shared.exchangeCodeForToken(code: code) { success in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                self.complitionHandler?(success)
            }
        }
    }
}

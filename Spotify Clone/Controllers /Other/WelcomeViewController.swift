//
//  WelcomeViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import UIKit

class WelcomeViewController: UIViewController {

    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    private let backgoundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "albums_backgound")
        return imageView
    }()
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "Millions of Songs.\nFree on Spotify."

        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

//        title = "Stopify"
        view.backgroundColor = .systemGreen
        view.addSubview(backgoundImageView)
        view.addSubview(overlayView)
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)

        view.addSubview(label)
        view.addSubview(logoImageView)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgoundImageView.frame = view.bounds
        overlayView.frame = view.bounds
        signInButton.frame = CGRect(x: 20, y: view.height - 70 - view.safeAreaInsets.bottom, width: view.width-40, height: 50)

        let logosize = view.width/2
        logoImageView.frame = CGRect(x: (view.width/2)-(logosize/2), y: (view.height-350)/2, width: (view.width)/2, height: (view.width)/2)

        label.frame = CGRect(x: 30, y: logoImageView.bottom+30, width: view.width-60, height: 150)
    }

    @objc func didTapSignIn() {
        let vc = AuthViewController()
            //in yt video he is using [weak self] here
        vc.complitionHandler = { success in
            // and using DispatchQueue.main.async HERE:
            self.handleSuccess(success: success)
        }

        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    private func handleSuccess(success: Bool)  {
        //Log user in or yell at them with error
        guard success else {
            let alert = UIAlertController(title: "Holy Moly!", message: "Something went sworng when signing in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)

            return
        }
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }
}

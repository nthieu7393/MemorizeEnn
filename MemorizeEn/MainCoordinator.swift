//
//  MainCoordinator.swift
//  Quizzie
//
//  Created by hieu nguyen on 03/11/2022.
//

import UIKit

class MainCoordinator {

    private var navigationController: UINavigationController
    var child: [UIViewController] {
        return navigationController.viewControllers
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        guard let viewController = ViewController.instantiate() else { return }
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    func back(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
    
    func goToSetsScreen() {
        guard let viewController = SetsViewController.instantiate() else { return }
        let presenter = SetsPresenter(
            view: viewController,
            storageService: storage!
        )
        viewController.presenter = presenter
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }

    func goToSignInScreen(delegatedView: SignInViewDelete) {
        guard let viewController = SignInViewController.instantiate() else { return }
        let presenter = SignInPresenter(authService: FirebaseAuthentication(), view: viewController)
        viewController.presenter = presenter
        viewController.coordinator = self
        viewController.delegate = delegatedView
        navigationController.pushViewController(viewController, animated: true)
    }

    func goToTermsScreen(set: SetTopicModel, topic: TopicModel?) {
        guard let topic = topic,
              let viewController = TermsViewController.instantiate() else { return }
        let presenter = TermsPresenter(
            view: viewController,
            set: set,
            topic: topic,
            storageService: FirebaseStorageService<TermModel>(
                authService: FirebaseAuthentication()
            ),
            networkVocabularyService: vocabularyService!
        )
        viewController.presenter = presenter
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }

    func presentTextMenuScreen(
            menuItems: [String],
            initialSelectedItemIndex: Int?,
            didSelectHandler: @escaping ((Int) -> Void)) {
        let viewController = TextMenuViewController.instantiate()
        viewController?.menuItems = menuItems
        viewController?.selectedItemIndex = initialSelectedItemIndex
        viewController?.didSelectHandler = didSelectHandler
        guard let viewController = viewController else { return }
        navigationController.topViewController?.present(viewController, animated: true)
    }

    func goToUserInfoScreen(delegatedView: UserInfoViewDelegate?) {
        guard let view = UserInfoViewController.instantiate() else { return }
        let presenter = UserInfoPresenter(
            authService: ServiceInjector.authenticationService,
            view: view
        )
        view.presenter = presenter
        view.coordinator = self
        view.delegate = delegatedView
        navigationController.pushViewController(view, animated: true)
    }

    func goToSignupScreen(delegateView: SignUpViewDelegate) {
        guard let view = SignUpViewController.instantiate() else { return }
        let presenter = SignUpPresenter(view: view, auth: ServiceInjector.authenticationService)
        view.presenter = presenter
        view.coordinator = self
        navigationController.show(view, sender: nil)
    }
}

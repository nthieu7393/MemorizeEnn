//
//  SetViewController.swift
//  Quizzie
//
//  Created by hieu nguyen on 03/11/2022.
//

import UIKit

class SetsViewController: BaseViewController {
    
    @IBOutlet weak var newSetContainerView: UIView!
    @IBOutlet weak var newSetButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var newSetToolBar: TextFieldToolbar?
    private var sets: [SetTopicModel] = []

    private lazy var newSetTextField: UITextField = {
        return UITextField()
    }()
    var setsPresenter: SetsPresenter? {
        return presenter as? SetsPresenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutInputNewSetToolbar()
        setsPresenter?.loadAllSets()
    }

    private func layoutInputNewSetToolbar() {
        view.addSubview(newSetTextField)
        newSetToolBar = TextFieldToolbar.fromNib()!
        newSetToolBar?.placeholder = Localizations.typeSetName
        newSetTextField.isHidden = true
        newSetTextField.inputAccessoryView = newSetToolBar
    }

    override func dismissKeyboard() {
        super.dismissKeyboard()
        newSetTextField.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newSetButton.addDashline(cornerRadius: CGFloat(Constants.borderRadius))
        view.window?.makeKeyAndVisible()
    }
    
    override func setupFontText() {
        newSetButton.tintColor = Colors.active
        newSetButton.setAttributedTitle(NSAttributedString(
            string: "+ \(Localizations.newSet)",
            attributes: [NSAttributedString.Key.font: Fonts.button!]
        ), for: .normal)
    }
    
    override var title: String? {
        get {
            return Localizations.set
        }
        set {}
    }
    
    override var rightBarButtonItems: [UIBarButtonItem]? {
        let backButton: UIButton = UIButton()
        backButton.setImage(Icons.sortIcon, for: UIControl.State())
        backButton.addTarget(self, action: #selector(sortButtonOnTap(_:)), for: UIControl.Event.touchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        return [leftBarButtonItem]
    }

    private func showMoreActionsBottomSheet(of set: SetTopicModel) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(
            title: "Edit name",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
                self.setsPresenter?.editNameOfSet(set)
            }
        let addTopicAction = UIAlertAction(
            title: "Add topic",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.setsPresenter?.createNewTopicToSet(set: set)
            }

        let deleteFolderAction = UIAlertAction(
            title: "Delete Folder",
            style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.setsPresenter?.deleteFolder(set)
            }

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel) { [weak self] _ in
                self?.dismiss(animated: true)
            }
        alert.addAction(editAction)
        alert.addAction(addTopicAction)
        alert.addAction(deleteFolderAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc func sortButtonOnTap(_ sender: Any) {
        // TODO: handle sort button on tap
        print("show sort popup")
    }
    
    @IBAction func newSetButtonOnTap(_ sender: UIButton) {
        setsPresenter?.createNewSet()
    }
}

extension SetsViewController: SetsView {

    func displayDataOfSets(sets: [SetTopicModel]) {
        self.sets = sets
        tableView.reloadData()
    }

    func displayNewSet(set: SetTopicModel) {
        sets.insert(set, at: 0)
        tableView.beginUpdates()
        tableView.insertSections(IndexSet(integer: 0), with: .fade)
        tableView.endUpdates()
    }

    func startInputNameOfSet(
        initialString: String,
        endEditing: @escaping (String?) -> Void
    ) {
        newSetTextField.becomeFirstResponder()
        newSetToolBar?.becomeFirstResponser(
            initialString: initialString,
            endEditing: { [weak self] string in
                guard let self = self else { return }
                self.dismissKeyboard()
                endEditing(string)
            }
        )
    }
}

extension SetsViewController: Storyboarded {}

extension SetsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sets.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets[section].topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: SetTableViewCell.self),
            for: indexPath
        ) as? SetTableViewCell
        cell?.setData(topic: sets[indexPath.section].topics[indexPath.row])
        return cell ?? UITableViewCell()
    }
}

extension SetsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let set = sets[indexPath.section]
        coordinator?.goToTermsScreen(set: set, topic: set.topics[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView: SetHeaderTableView = SetHeaderTableView.fromNib() else { return UIView() }
        headerView.setData(set: sets[section]) { [weak self] in
            guard let self = self else { return }
            self.showMoreActionsBottomSheet(of: self.sets[section])
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            setsPresenter?.deleteTopic(sets[indexPath.section].topics[indexPath.row], from: sets[indexPath.section])
            sets[indexPath.section].topics.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

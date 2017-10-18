//
//  FavoritesViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/10/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

protocol NavBarDelegate {
    var navBarHeight: CGFloat { get }
}

class FavoritesViewController: UIViewController, NavBarDelegate {
    
    var tableView = UITableView()
    let emptyStateView = EmptyStateView()
    
    let manager: APODManager!
    
    var navBarHeight: CGFloat {
        return navigationController!.navigationBar.bounds.height
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(manager: APODManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupConstraints()
        manager.favorites.favoritesViewController = self
        manager.favorites.initializeFetchedResultsController()
        
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationItem.title = StyleManager.Text.favoritesTitle.uppercased()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fadeInView()
        manager.favorites.initializeFetchedResultsController()
        checkForInexPath()
    }
    
    func fadeInView() {
        view.alpha = 0
        UIView.animate(withDuration: StyleManager.Animation.fadeDuration) {
            self.view.alpha = 1
        }
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(FavoritesTableViewCell.self, forCellReuseIdentifier: FavoritesTableViewCell.identifier)
        tableView.delegate = manager.favorites
        tableView.dataSource = manager.favorites
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 1
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            view.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func checkForInexPath() {
        // checking for a saved indexPath and that it is valid for the tableView
        if let ip = manager.favorites.indexPath {
            if tableView.numberOfSections > ip.section,
                tableView.numberOfRows(inSection: ip.section) > ip.row {
                tableView.scrollToRow(at: ip, at: .top, animated: false)
            } else {
                let ip = IndexPath(row: tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1, section: tableView.numberOfSections - 1)
                tableView.scrollToRow(at: ip, at: .bottom, animated: false)
            }
        }
    }
    
    @objc func editButtonPressed() {
        tableView.setEditing(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }
    
    @objc func doneButtonPressed() {
        tableView.setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: { (context) in
//            print("Navbar height: ", self.navigationController?.navigationBar.frame.height)
//        }) { (context) in
//        }
//    }
}

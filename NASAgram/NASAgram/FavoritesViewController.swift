//
//  FavoritesViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/10/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    var tableView = UITableView()
    
    let manager: APODManager!
    
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
        manager.favorites.tableView = tableView
        manager.favorites.favoritesViewController = self
        manager.favorites.initializeFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        manager.favorites.initializeFetchedResultsController()
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(FavoritesTableViewCell.self, forCellReuseIdentifier: FavoritesTableViewCell.identifier)
        tableView.delegate = manager.favorites
        tableView.dataSource = manager.favorites
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
    }
    
    func setupConstraints() {
        edgesForExtendedLayout = []
        tableView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(topLayoutGuide.snp.bottom)
            view.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
    }
}

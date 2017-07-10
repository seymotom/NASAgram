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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupConstraints()
        FavoritesManager.shared.initializeFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FavoritesManager.shared.initializeFetchedResultsController()
        tableView.reloadData()
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(FavoritesTableViewCell.self, forCellReuseIdentifier: FavoritesTableViewCell.identifier)
        tableView.delegate = FavoritesManager.shared
        tableView.dataSource = FavoritesManager.shared
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

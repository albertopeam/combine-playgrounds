//
//  ContentView.swift
//  ReplaySubject
//
//  Created by Alberto Penas Amor on 10/03/2020.
//  Copyright © 2020 com.github.albertopeam. All rights reserved.
//

import UIKit
import Combine

class ContentViewController: UIViewController, UITableViewDataSource {

    private let tableView: UITableView = .init(frame: .zero, style: .plain)
    private let viewModel: ContentViewModel
    private var subscriptions: Set<AnyCancellable> = .init()
    private var items: [ContentViewModel.Model] = .init() {
        didSet {
            tableView.reloadData()
        }
    }

    init(viewModel: ContentViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        viewModel.subject.assign(to: \.items, on: self).store(in: &subscriptions
        )
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))!
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }
}

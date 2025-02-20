//
//  WishlistViewController.swift
//  Plexus
//
//  Created Anik on 19/8/19.
//  Copyright © 2019 A7Studio. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import UIKit

class WishlistViewController: UIViewController, WishlistViewProtocol {

    @IBOutlet weak var wishlistTableView: UITableView!
    var presenter: WishlistPresenterProtocol?

	override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        wishlistTableView.delegate = self
        wishlistTableView.dataSource = self
        wishlistTableView.register(UINib(nibName: "WishlistCell", bundle: nil), forCellReuseIdentifier: "wishlistCell")
    }
}

extension WishlistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellWidth : CGFloat = 166.0;
        return cellWidth;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishlistCell", for: indexPath) as! WishlistCell
        cell.layer.backgroundColor = UIColor.clear.cgColor
        return cell
    }
}

//
//  ProfileViewController.swift
//  Plexus
//
//  Created Anik on 19/8/19.
//  Copyright © 2019 A7Studio. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import UIKit

class ProfileViewController: UIViewController, ProfileViewProtocol {

    @IBOutlet weak var profileCoursesTableview: UITableView!
    var presenter: ProfilePresenterProtocol?

	override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        profileCoursesTableview.delegate = self
        profileCoursesTableview.dataSource = self
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellWidth : CGFloat = 166.0;
        return cellWidth;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "topRatedParentCell", for: indexPath) as! TopRatedParentCell
            cell.layer.backgroundColor = UIColor.clear.cgColor
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "completedParentCell", for: indexPath) as! CompletedParentCell
            cell.layer.backgroundColor = UIColor.clear.cgColor
            return cell
        }
        
    }
}

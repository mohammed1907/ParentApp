//
//  ViewController.swift
//  ParentApp
//
//  Created by Youm7 on 8/6/20.
//  Copyright © 2020 Test.iosapp. All rights reserved.
//

import UIKit
import Firebase
class ChildViewController: UIViewController,RefreshChildsDelegate {
  
    
    
    
     var users = [User]()
    
    
    @IBOutlet weak var childssTabelView: UITableView!
  var handle: AuthStateDidChangeListenerHandle?
    override func viewDidLoad() {
        super.viewDidLoad()

        let AddConditionBarButtonItem = UIBarButtonItem(image: UIImage(named: "addchild"), style: .plain, target: self, action: #selector(addCondition))
        self.navigationItem.rightBarButtonItem  = AddConditionBarButtonItem
        navigationController?.navigationBar.barTintColor = UIColor.maincolor
        
        self.title = "Childs"
        childssTabelView.dataSource = self
        childssTabelView.delegate = self
        childssTabelView.tableFooterView = UIView()
        childssTabelView.register(UINib.init(nibName: "ChildsTableViewCell", bundle: nil), forCellReuseIdentifier: ChildsTableViewCell.identifier)
        fetchUser()
        // Do any additional setup after loading the view.
    }
    func fetchUser() {
        self.users.removeAll()
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.key = snapshot.key
                self.users.append(user)
                DispatchQueue.main.async(execute: {
                    self.childssTabelView.reloadData()
                })
            }
            
            }, withCancel: nil)
    }
    func refreshchilds() {
          fetchUser()
      }
    override func viewWillAppear(_ animated: Bool) {
          handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // [START_EXCLUDE]
//            self.setTitleDisplay(user)
            
            self.childssTabelView.reloadData()
            // [END_EXCLUDE]
          }
    }
    @objc func addCondition(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: RegisterChildViewController.identifier) as! RegisterChildViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)

    }

}
extension ChildViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChildsTableViewCell.identifier, for: indexPath) as! ChildsTableViewCell
        cell.setupChildData(user: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
              let user = users[indexPath.row]
              let vc = self.storyboard?.instantiateViewController(withIdentifier: MapDetailsViewController.identifier) as! MapDetailsViewController
                  vc.users = user
                 
                self.navigationController?.pushViewController(vc, animated: true)
              


    }
    
}

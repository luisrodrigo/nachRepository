//
//  GraphicsViewController.swift
//  TestNachiOS
//
//  Created by Luis Rodrigo Gonzalez Vazquez on 06/03/22.
//

import UIKit
import Charts
import ProgressHUD
import FirebaseDatabase

class GraphicsViewController: UITableViewController {
    
    var dataManager = DataManager()
    let players = ["Ozil", "Ramsey", "Laca", "Auba", "Xhaka", "Torreira"]
    let goals = [6, 8, 26, 30, 8, 10]
    var responses: [String] = []
    var values: [Double] = []
    var content: UrlData?
    
    let backgroundColorRef = Database.database().reference().child("backgroundColor")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNibs()
        ProgressHUD.show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dataManager.delegate = self
        dataManager.performaRequest()
        backgroundColorRef.observe(DataEventType.value, with: { snapshot in
            if let color = snapshot.value{
                self.view.backgroundColor = hexStringToUIColor(hex: color as? String ?? "#ffffff")
            }
        })
    }
    
    
    func registerNibs(){
        tableView.register(UINib(nibName: "ChartCell", bundle: Bundle.main), forCellReuseIdentifier: "ChartCell")
    }
}

extension GraphicsViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.content?.questions.count{
            return count
        }else{
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell", for: indexPath) as! ChartCell
        cell.selectionStyle = .none
        if let dataContent = content{
            let responses = dataContent.questions[indexPath.row].chartData.compactMap{$0.text}
            let values = dataContent.questions[indexPath.row].chartData.compactMap{Double($0.percetnage)}
            let questionTitle = dataContent.questions[indexPath.row].text
            let colors = dataContent.colors
            cell.configure(dataPoints: responses, values: values.map{ Double($0)}, questionTitle: questionTitle, colors: colors)
        }
        return cell
    }
}

extension GraphicsViewController: urlDataDelegate{
    func getQuestions(content : UrlData) {
        DispatchQueue.main.async {
            self.content = content
            ProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }
    
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//
//  ViewController.swift
//  SQLiteManager
//
//  Created by ios on 15/06/2017.
//  Copyright © 2017 mellow. All rights reserved.
//

import UIKit

class User: ORMModel {
    var name: String?
    var age: NSInteger?
    var car: Car?
    var printer: Printer?
}

class Car: ORMModel {
    var number: String?
    var brand: String?
}

class Printer: ORMModel {
    var name: String?
    var model: String?
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "数据库测试"
        
        let printer = Printer()
        printer.id = "printer_id_000"
        printer.name = "Brother"
        printer.model = "AA-8f"
        
        let car = Car()
        car.id = "car_id_000"
        car.number = "A8888"
        car.brand = "BMW"
        
        let tom = User()
        tom.id = "user_id_000"
        tom.name = "tom"
        tom.age = 18
        tom.car = car
        tom.printer = printer
        
        SQLiteManager.shared.insert(object: car)
        SQLiteManager.shared.insert(object: printer)
        SQLiteManager.shared.insert(object: tom)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


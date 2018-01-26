//
//  PickNasaDateViewController.swift
//  NASA APOD
//
//  Created by Riyazh Dholakia on 10/3/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit

class DateSelectViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateChange.maximumDate = Date()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dateChange.setDate(selectedDate, animated: true)
    }
    
    @IBOutlet weak var dateChange: UIDatePicker!
    
    var selectedDate = Date()
    
    @IBAction func onNasaDatePickChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @IBAction func onRandomDateSelect(_ sender: UIButton) {
        Date(timeInterval: onRandomDateSelect(UIButton), since: self)
        onRandomDateSelected()
    }
    
    func onRandomDateSelected(){
        let today = Date()
        let calendar = Calendar.current
        let todaysYear = calendar.component(.year, from: today)
        let todaysMonth = calendar.component(.month, from: today)
        let todaysDay = calendar.component(.day, from: today)
        let differenceInYears = todaysYear - 1995
        // 22 if this is still 2017 when you next read this
        let randomYearDifference = Int(arc4random_uniform(UInt32(differenceInYears)))
        let randomYear = randomYearDifference + 1995
        let randomMonth = Int(arc4random_uniform(UInt32(12)) + 1)
        let randomDay = Int(arc4random_uniform(UInt32(31)) + 1)
        let components = DateComponents(calendar: calendar, year: randomYear, month: randomMonth, day: randomDay)
        var priorDates: [Date] = []
        if let priorDate = components.date {
            priorDates.append(priorDate)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pastTenYearsVC = segue.destination as? PastTenYearsCollectionViewController {
            pastTenYearsVC.priorDates = lastTenYearsOn(selectedDate: selectedDate)
        }
    }
    
    func lastTenYearsOn(selectedDate: Date) -> [Date] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        let day = calendar.component(.day, from: selectedDate)
        var priorDates: [Date] = []
        for yearsBack in 0...9 {
            let components = DateComponents(calendar: calendar, year: year - yearsBack, month: month, day: day)
            if let priorDate = components.date {
                priorDates.append(priorDate)
            }
        }
        return priorDates
    }
}

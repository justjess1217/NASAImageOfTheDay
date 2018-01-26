//
//  Model.swift
//  NASA APOD
//
//  Created by Jess Telmanik on 10/16/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit

class Apod: Decodable {
    
    let explanation: String
    let title: String
    let url: URL
    
    var theDate: Date?
    var imageData: Data?
    var image: UIImage? {
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
}

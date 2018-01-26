//
//  PastTenYearsCollectionController.swift
//  NASA APOD
//
//  Created by Jess Telmanik on 10/4/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
//import CBNetworking
import SafariServices

class PastTenYearsCollectionViewController: UICollectionViewController {
    
    var priorDates: [Date] = []
    var apods: [Apod] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        title = formatter.string(from: priorDates[0])
        formatter.dateFormat = "yyyy-MM-dd"
        
        for date in priorDates {
            let apiKey = "4BSCHvrqBaQOhZ3mXGG3FeHaqX6B3aGtnoEQr7iX"
            let stringDate = formatter.string(from: date)
            let urlString = "https://api.nasa.gov/planetary/apod?api_key=" + apiKey + "&date=" + stringDate
            let url = URL(string: urlString)!
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let data = data {
                    let apod = try! JSONDecoder().decode(Apod.self, from: data)
                    apod.theDate = date
                    self.apods.append(apod)
                    URLSession.shared.dataTask(with: apod.url, completionHandler: { (data, response, error) in
                        apod.imageData = data
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }).resume()
                }
            }).resume()
        }
    }
    
    func onApodDownloaded(data: Data?, response: URLResponse?, error: Error?) {
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apods.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "acell", for: indexPath) as! PastTenYearsCollectionViewCell
        cell.pastImageCell.image = apods[indexPath.row].image ?? #imageLiteral(resourceName: "nasafail")
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedApod = apods[indexPath.row]
        requestApodURL(for: selectedApod.theDate!, completion: onUrlCompleted)
    }
    
    func onUrlCompleted(url: URL?, error: Error?) {
        if let url = url {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        } else {
            print(error)
        }
    }
}

//
//  RootViewController.swift
//  NASA APOD
//
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CBNetworking
import SafariServices

class RootViewController: UIViewController {
    
    @IBAction func onSharedNavButtonPressed(_ sender: UIBarButtonItem) {
        let saveAlert = UIAlertController(title: "Share URL or Image", message: nil, preferredStyle: .actionSheet)
        saveAlert.addAction(UIAlertAction(title: "Share URL", style: .default, handler: onShareUrlTap))
        saveAlert.addAction(UIAlertAction(title: "Share Image", style: .default, handler: onSharedImageTapped))
        present(saveAlert, animated: true, completion: nil)
    }
    
    @IBAction func onSafariViewPressed(_ sender: UIButton) {
        requestApodURL(for: selectedDate, completion: onUrlCompleted)
    }
    
    @IBAction func onApodImageLongPressed(_ sender: Any) {
        let saveAlert = UIAlertController(title: "Save Image?", message: nil, preferredStyle: .actionSheet)
        saveAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: onImageSaved))
        saveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(saveAlert, animated: true, completion: nil)
    }
    
    @IBAction func unwindFromPickNasaDateVC(segue: UIStoryboardSegue){
        let nasaSelectVC = segue.source as! DateSelectViewController
        selectedDate = nasaSelectVC.selectedDate
        refresh()
        setTitleDate()
    }
    
    @IBAction func onRefreshedNavPressed(_ sender: UIBarButtonItem) {
        refresh()
    }
    
    
    @IBOutlet var apodImageView: UIImageView!
    @IBOutlet weak var apodTitleLabel: UILabel!
    @IBOutlet weak var textViewDescription: UITextView!
    
    
    var selectedDate = Date()
    var apod: Apod?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleDate()
        refresh()
        let urlString = "https://api.nasa.gov/planetary/apod?api_key=4BSCHvrqBaQOhZ3mXGG3FeHaqX6B3aGtnoEQr7iX&date="
        let url = URL(string: urlString)!
        URLSession.shared.dataTask(with: url, completionHandler: onApodDownloaded).resume()
    }
    
    func onApodDownloaded(data: Data?, response: URLResponse?, error: Error?){
        if let data = data, let apod = try? JSONDecoder().decode(Apod.self, from: data) {
            self.apod = apod
            DispatchQueue.main.async {
                self.apodTitleLabel.text = apod.title
                self.textViewDescription.text = apod.explanation
                self.apodImageView.image = apod.image
            }
            URLSession.shared.dataTask(with: apod.url, completionHandler: onApodImageDownloaded).resume()
        }
    }
    
    func onApodImageDownloaded(data: Data?, response: URLResponse?, error: Error?){
        if let data = data {
            self.apod?.imageData = data
            DispatchQueue.main.async {
                self.apodImageView.image = self.apod?.image
            }
        }
    }
    
    func onShareUrlTap(action: UIAlertAction){
        requestApodURL(for: selectedDate, completion: onUrlForSharingDownloaded)
    }
    
    func onUrlForSharingDownloaded(url: URL?, error: Error?){
        if let urlDownloaded = url {
            let shareActivityVC = UIActivityViewController(activityItems: [urlDownloaded], applicationActivities: nil)
            present(shareActivityVC, animated: true, completion: nil)
        }
    }
    
    func onSharedImageTapped(action: UIAlertAction){
        if let imageToShare = apodImageView.image{
            let shareActivityVC = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
            present(shareActivityVC, animated: true, completion: nil)
        }
    }
    
    func onImageSaved(action: UIAlertAction) {
        if let imageToSave = apodImageView.image{
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        }
        print("Save Image")
    }
    
    func show(error: Error?) {
        let message = error?.localizedDescription
        let alert = UIAlertController(title: "Browser Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func onUrlCompleted(url: URL?, error: Error?) {
        if let url = url {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        } else {
            show(error: error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController{
            if let pickNasaVC = navController.childViewControllers.first as? DateSelectViewController{
                pickNasaVC.selectedDate = selectedDate
            }
        }
    }
    
    func setTitleDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        title = formatter.string(from: selectedDate)
    }
    
    func refresh(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestApodImage(for: selectedDate, completion: onImageDownloaded)
    }
    
    func onApodTitleLabelDownloaded(title: String?, error: Error?) {
        if title == nil {
            show(error: error)
        } else {
            apodTitleLabel.text = title
            requestApodDescription(for: selectedDate, completion: onTextViewDownloaded)
        }
    }
    
    func onImageDownloaded(image: UIImage?, error: Error?) {
        if let imageUnwrapped = image {
            apodImageView.image = imageUnwrapped
            requestApodTitle(for: selectedDate, completion: onApodTitleLabelDownloaded)
        } else if let error = error as? ApodError, error == .imageUnavailable {
            apodImageView.image = #imageLiteral(resourceName: "nasafail")
            apodTitleLabel.text = "Try Safari View?"
            textViewDescription.isHidden = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        } else {
            show(error: error)
        }
    }
    
    func onTextViewDownloaded(textView: String?, error: Error?) {
        if textView == nil {
            show(error: error)
        } else {
            textViewDescription.text = textView
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

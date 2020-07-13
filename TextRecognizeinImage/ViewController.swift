//
//  ViewController.swift
//  TextRecognizeinImage
//
//  Created by Ji Chang Hyun on 2020/07/13.
//  Copyright © 2020 Nigostarr. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopAnimating()
    }
    
    
    private func startAnimating() {
        self.activityIndicator.startAnimating()
    }
    private func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }

    @IBAction func touchUpInsideCameraButton(_ sender: Any) {
        setupGallery()
    }
    
    private func setupGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePhotoLibraryPicker = UIImagePickerController()
            imagePhotoLibraryPicker.delegate = self
            imagePhotoLibraryPicker.allowsEditing = true
            imagePhotoLibraryPicker.sourceType = .photoLibrary
            self.present(imagePhotoLibraryPicker, animated: true, completion: nil)
        }
    }
    
    private func setupVisionTextRecognizeImage(image: UIImage?) {
        
        //setupTextRecognition
        var textString = ""
        
        request = VNRecognizeTextRequest(completionHandler: {(request,error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {fatalError("Recieved Invalid Observation")}
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {print("No candidate")
                    continue
                    
                }
                textString += "\n\(topCandidate.string)"
            }
            
            
            DispatchQueue.main.async {
                self.stopAnimating()
                self.textView.text = textString
            }
        })
        
        // add some properties
        
        request.customWords = ["custom"]
        request.minimumTextHeight = 0.03125
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]
        request.recognitionLanguages = ["ko_KR.UTF-8"]
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        // creating request handler
        
        DispatchQueue.global(qos: .userInitiated).async{
            guard let img = image?.cgImage else{fatalError("Missing to scan")}
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try? handle.perform(requests)
       }
    }
 }

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        startAnimating()
        self.textView.text = ""
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imageView.image = image
        
        setupVisionTextRecognizeImage(image: image)
    }
}

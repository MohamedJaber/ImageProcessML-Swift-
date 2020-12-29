//
//  ViewController.swift
//  ImageProcessML
//
//  Created by Mohamed Jaber on 17/12/2020.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    let imagePicker=UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate=self
        imagePicker.sourceType = .camera
        //imagePicker.sourceType = .photoLibrary //If we want the user to choose a pic instead of taking one via camera.
        imagePicker.allowsEditing=false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage=info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image=userPickedImage
            guard let ciimage = CIImage(image: userPickedImage)else{
                fatalError("Can't convert Image to CoreImageImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model)else{
            fatalError("Loading CoreML Model failed")
        }
        let request=VNCoreMLRequest(model: model) { (request, error) in
            guard let results=request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed to process image")
            }
            if let firstResult=results.first{
                self.navigationItem.title="\(firstResult.identifier)"
                //Text to Speech
                let utTerance = AVSpeechUtterance(string: "\(firstResult.identifier)")
                utTerance.voice = AVSpeechSynthesisVoice(language: "en-gb")
                let Synthesizer = AVSpeechSynthesizer()
                Synthesizer.speak(utTerance)
            }
        }
        let handler=VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    

}


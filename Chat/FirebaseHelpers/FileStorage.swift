//
//  FileStorage.swift
//  Chat
//
//  Created by David Kababyan on 07/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseStorage

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        if Reachability.HasConnection() {
                        
            let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
            
            let imageData = image.jpegData(compressionQuality: 0.5)
            
            var task : StorageUploadTask!
                    
            
            task = storageRef.putData(imageData!, metadata: nil, completion: {
                metadata, error in
                
                task.removeAllObservers()
                
                if error != nil {
                    
                    print("error uploading document \(error!.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL(completion: { (url, error) in
                    
                    guard let downloadUrl = url else {
                        completion(nil)
                        return
                    }

                    completion(downloadUrl.absoluteString)
                })
                
            })
            
        } else {
            print("No Internet Connection!")
        }
    }



    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = ((imageUrl.components(separatedBy: "_").last!).components(separatedBy: "?").first!).components(separatedBy: ".").first!

        if fileExistsAtPath(path: imageFileName) {

            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: imageFileName)) {
                completion(contentsOfFile)

            } else {
                print("couldn't generate local image")
                completion(UIImage(named: "samplePhoto"))
            }
            
        } else {

            if imageUrl != "" {

                let documentURL = URL(string: imageUrl)
                
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")

                downloadQueue.async {
                    
                    let data = NSData(contentsOf: documentURL!)
                    
                    if data != nil {
                                    
                        let imageToReturn = UIImage(data: data! as Data)
                        
                        DispatchQueue.main.async {
                            completion(imageToReturn!)
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            print("No document in database")
                            completion(nil)
                        }
                    }
                }

            } else {
                completion(UIImage(named: "samplePhoto"))
            }
        }
    }
    
       
    class func saveImageLocally(imageData: Data, fileName: String) {
        
        var docURL = getDocumentsURL()
        
        docURL = docURL.appendingPathComponent(fileName, isDirectory: false)
        
        (imageData as NSData).write(to: docURL, atomically: true)
    }

}

//Helpers
func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
}

func getDocumentsURL() -> URL {
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last

    return documentURL!
}


func fileExistsAtPath(path: String) -> Bool {
    
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(filename: path)
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist
}


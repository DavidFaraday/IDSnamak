//
//  FileStorage.swift
//  Chat
//
//  Created by David Kababyan on 07/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    //MARK: - Image
    
    class func uploadImage(_ image: UIImage, directory: String, isThumbnail: Bool = false, completion: @escaping (_ documentLink: String?) -> Void) {
        
        if Reachability.HasConnection() {
            
            let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
            
            let imageData = image.jpegData(compressionQuality: isThumbnail ? 0.3 : 0.7)
            
            var task : StorageUploadTask!
            
            
            task = storageRef.putData(imageData!, metadata: nil, completion: {
                metadata, error in
                
                task.removeAllObservers()
                ProgressHUD.dismiss()
                
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
            
            if !isThumbnail {
                task.observe(StorageTaskStatus.progress, handler: {
                    snapshot in
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    ProgressHUD.showProgress(CGFloat(progress))
                })
            }
            
        } else {
            print("No Internet Connection!")
        }
    }
    
    
    class func downloadImage(imageUrl: String, isMessage: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = fileNameFrom(fileUrl: imageUrl)

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
                        
                        //save locally if its a message
                        if isMessage {
                            FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        }
                        
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
    
    
    //MARK: - Video
    class func uploadVideo(video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        
        if Reachability.HasConnection() {
                        
            let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
            var task : StorageUploadTask!
            
            task = storageRef.putData(video as Data, metadata: nil, completion: {
                metadata, error in
                
                task.removeAllObservers()
                ProgressHUD.dismiss()

                if error != nil {
                    print("error uploading video \(error!.localizedDescription)")
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
            
            task.observe(StorageTaskStatus.progress, handler: {
                snapshot in
                let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                ProgressHUD.showProgress(CGFloat(progress))
            })
            
            
        } else {
            print("No Internet Connection!")
        }
        
    }
    
    class func downloadVideo(videoUrl: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        
        let videoURL = URL(string: videoUrl)
        let videoFileName = fileNameFrom(fileUrl: videoUrl) + ".mov"
        
        
        if fileExistsAtPath(path: videoFileName) {

            completion(true, videoFileName)
            
        } else {
            
            let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
            
            downloadQueue.async {

                let data = NSData(contentsOf: videoURL!)
                
                if data != nil {
                    
                    FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                    
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                    
                } else {
                    print("No Video in database")
                }
            }
        }
    }
    
    
    
    //MARK: - Save locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        
        var docURL = getDocumentsURL()
        
        docURL = docURL.appendingPathComponent(fileName, isDirectory: false)
        
        (fileData as NSData).write(to: docURL, atomically: true)
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


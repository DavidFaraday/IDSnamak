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
                completion(UIImage(named: "avatar"))
            }

        } else {

            if imageUrl != "" {

                let documentURL = URL(string: imageUrl)

                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")

                downloadQueue.async {

                    let data = NSData(contentsOf: documentURL!)

                    if data != nil {

                        let imageToReturn = UIImage(data: data! as Data)

                        //save all
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)

                        //save locally if its a message
//                        if isMessage {
//                            FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
//                        }

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
                completion(UIImage(named: "avatar"))
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
    
    //MARK: - Audio
    
    class func uploadAudio(audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        
        let fileName = audioFileName + ".m4a"

        if Reachability.HasConnection() {
            
            let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
            var task : StorageUploadTask!
            
            if fileExistsAtPath(path: fileName) {
                
                if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(filename: fileName)) {
                    
//                    let bcf = ByteCountFormatter()
//                    bcf.allowedUnits = [.useBytes] // optional: restricts the units to MB only
//                    bcf.countStyle = .file
//                    let string = bcf.string(fromByteCount: Int64(audioData.count))
//                    print("formatted result: \(string)")
//                    print("have audio data", audioData)
                    
                    task = storageRef.putData(audioData as Data, metadata: nil, completion: {
                        metadata, error in
                        
                        task.removeAllObservers()
                        ProgressHUD.dismiss()
                        
                        if error != nil {
                            print("error uploading audio \(error!.localizedDescription)")
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
                    print("nil data")
                }
                
            } else {
                print("NOTHING TO UPLOAD")
            }
            
        } else {
            print("No Internet Connection!")
        }
        
    }

    
    class func downloadAudio(audioUrl: String, completion: @escaping ( _ audioFileName: String) -> Void) {

        let audioFileName = fileNameFrom(fileUrl: audioUrl)  + ".m4a"

        if fileExistsAtPath(path: audioFileName) {

            completion(audioFileName)

        } else {

            let downloadQueue = DispatchQueue(label: "audioDownloadQueue")

            downloadQueue.async {

                let data = NSData(contentsOf: URL(string: audioUrl)!)

                if data != nil {

                    FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)

                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }

                } else {
                    print("No audio in database")
                }
            }
        }
    }
    
    //MARK: - Save locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }

}

//MARK: - Helpers
func fileInDocumentsDirectory(filename: String) -> String {
    return getDocumentsURL().appendingPathComponent(filename).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}


func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(filename: path))
}


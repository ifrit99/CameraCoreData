//
//  ViewController.swift
//  CameraCoreData
//
//  Created by 金井英晃 on 2020/07/12.
//  Copyright © 2020 ifrit. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    // エンティティから引っ張ってきたデータを格納する用の配列
    var photoEntity:[Photo?] = []
    
    // マネージドオブジェクトコンテキストのオブジェクト化
    var conText = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // 起動時の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 起動時にCoreDataから画像を取り出してImageViewに表示する
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        do {
            photoEntity = try conText.fetch(fetchRequest)
            let image = photoEntity.last??.picture
            
            if let validImage = image {
                let imageData = UIImage(data: validImage)
                self.imageView.image = imageData
            } else {
                // 処理なし
            }
        } catch {
            print(error)
        }
    }

    // 写真を表示するImageView
    @IBOutlet weak var imageView: UIImageView!
    
    // Saveボタン(PhotoLibraryへ保存する)
    @IBAction func tapSaveButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // PhotoLibraryボタン
    @IBAction func tapPhotoLibraryButton(_ sender: Any) {
        openPicker(type: .photoLibrary)
    }
    
    // カメラ起動ボタン
    @IBAction func tapCameraButton(_ sender: Any) {
        openPicker(type: .camera)
    }
    
    // カメラ起動処理
    func openPicker(type: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    // 撮った写真をImageViewに表示する
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = image
        
        // 画像をCoreDataへ保存
        let photoCore = Photo(context: self.conText)
        let imageData = UIImage.pngData(image)
        photoCore.picture = imageData()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // カメラ起動キャンセル
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 写真の保存処理
    @objc func saveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        if error == nil {
            print("save success")
        }
    }

}


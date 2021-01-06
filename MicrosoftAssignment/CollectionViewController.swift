//
//  CollectionViewController.swift
//  MicrosoftAssignment
//
//  Created by Talha Khalid on 12/22/20.
//  Copyright © 2020 TalhaKhalid. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "CustomCell"

class CollectionViewController: UICollectionViewController {

    var assetsFetchResults: PHFetchResult<PHAsset>?
    var selectedAssets: [PHAsset] = []
        
     private let sectionNames = ["", "", "Albums"]
     private var userAlbums: PHFetchResult<PHAssetCollection>?
     private var userFavorites: PHFetchResult<PHAssetCollection>?
    
    private var userFavoritesAssets: [PHAsset] = []
    
    private let numOffscreenAssetsToCache = 60
    
    private var cellSize: CGSize {
      get {
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
      }
    }
    
    let requestOptions: PHImageRequestOptions = {
      let o = PHImageRequestOptions()
      o.isNetworkAccessAllowed = true
      o.resizeMode = .fast
      return o
    }()
    
    override func viewDidLoad() {
      super.viewDidLoad()
        self.collectionView!.register(CustomCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        /*
      PHPhotoLibrary.requestAuthorization { (status) in
        DispatchQueue.main.async {
          switch status {
          case .authorized:
            self.fetchCollections()
            self.collectionView.reloadData()
          default:
            self.showNoAccessAlert()
          }
        }
      }
        */
        
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                DispatchQueue.main.async {
                  switch status {
                  case .authorized:
                    self.fetchCollections()
                    self.collectionView.reloadData()
                  default:
                    self.showNoAccessAlert()
                  }
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        
    }
    
    func fetchCollections() {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
      if let albums = PHCollectionList.fetchTopLevelUserCollections(with: nil) as? PHFetchResult<PHAssetCollection> {
        userAlbums = albums
      }
      userFavorites = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        
        userFavorites?.enumerateObjects({ (object, index, stop) in
            let collection = object
            let result = PHAsset.fetchAssets(in: collection, options: options)
            
            result.enumerateObjects { (object, index, stop) in
                let asset = object
                self.userFavoritesAssets.append(asset)
            }
        })
        
        assetsFetchResults = PHAsset.fetchAssets(with: options)
        
    }
    
    private func showNoAccessAlert() {
      let alert = UIAlertController(title: "No Photo Access",
                                    message: "Please grant Stitch photo access in Settings -> Privacy",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        //self.cancelPressed(self)
      }))
      alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:])
        }
      }))
      present(alert, animated: true, completion: nil)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        //updateSelectedItems()
    }
    
    func currentAssetAtIndex(_ index:NSInteger) -> PHAsset {
      if let fetchResult = assetsFetchResults {
        return fetchResult[index]
      } else {
        return selectedAssets[index]
      }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let fetchResult = assetsFetchResults {
          return fetchResult.count
        } else {
          return selectedAssets.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomCell
        
        //let asset = currentAssetAtIndex(indexPath.item)
        
        // switch to, in case of favorites
        
        // @Fayyaz - this right now only displays Favorite photos
        // you should ideally be able to toggle though
        
        var index = indexPath.item
        
        var asset: PHAsset?
        
        if index > 0 && index < userFavoritesAssets.count{
            asset = userFavoritesAssets[index]
        }
        
        if let asset = asset{
            
            //Fayyaz - is this a performance issue? doing a call like .requestImage inside the cellForItemAt function ?
            
            PHImageManager.default().requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: requestOptions) { (image, metadata) in
                    
                DispatchQueue.main.async {
                    cell.myImageView.image = image
                }
            }
            
        }
        
        
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

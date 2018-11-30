//
//  ZLPhotoEditorController.swift
//  WeScan
//
//  Created by apple on 2018/11/30.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
private let kCollectionCellIdentifier = "kCollectionCellIdentifier"
class ZLPhotoEditorController: UIViewController {
    
    @IBOutlet weak var oneToolBarViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var twoToolBarViewBottomCons: NSLayoutConstraint!
    
    @IBOutlet weak var oneToolBarView: UIView!
    @IBOutlet weak var twoToolBarView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: kCollectionCellIdentifier)
        
        view.backgroundColor = UIColor.white
        title = "1/11"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back", in: Bundle(for: self.classForCoder), compatibleWith: nil), style: .plain, target: self, action: #selector(pop))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "sort", style: .plain, target: self, action: #selector(sortResource))
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - DataSource And Delegate
extension ZLPhotoEditorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionCellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.orange
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
}


// MARK: - Event
extension ZLPhotoEditorController {
    @objc fileprivate func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func sortResource() {
        
    }
}

//
//  HovedMenu.swift
//  FlexicuV2
//
//  Created by Janus Olsen on 14/11/2018.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HovedMenu: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var CollectionView1: UICollectionView! //Udlejede
    
    @IBOutlet weak var CollectionView2: UICollectionView! // Lejede
    
    @IBOutlet weak var CollectionView3: UICollectionView! // Alle ens medarbejdere
    
    let udlejedeMIdentifier = "udlejedeMCell"
    let lejetACVIdentifier = "lejetArbejdskraftCell"
    let alleMCVIdentifier = "alleMedarbejdereCell"
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: Notification.Name.readData, object: nil, queue: OperationQueue.main) { (notification) in
            print("Opdatering medarbejder incoming")
            self.CollectionView3.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.readAftaler, object: nil, queue: OperationQueue.main) { (notification) in
            print("Opdatering aftaler incoming")
            
            self.CollectionView1.reloadData()
            self.CollectionView2.reloadData()
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let height = (self.view.frame.size.width/5)
//        return CGSize(width: 131.0, height: height)
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.CollectionView1 {
            if(VirkSingleton.shared.udlejedeFolk.count > 0) {
                return VirkSingleton.shared.udlejedeFolk.count
            }
            else {
                return 0
            }
        }
        else if collectionView == self.CollectionView2 {
            if(VirkSingleton.shared.indlejedeFolk.count > 0) {
                return VirkSingleton.shared.ledigFolk.count
            }
            else {
                return 0
            }
        }
        else{
            if(VirkSingleton.shared.virksomhed?.medarbejdere.count != nil){
                return ((VirkSingleton.shared.virksomhed?.medarbejdere.count)! + 1)// returner længden på datasættene
            }
            else {
                return 1
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.CollectionView3.reloadData()
        self.CollectionView1.reloadData()
        self.CollectionView2.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == CollectionView1 {
            let cell: UdlejedeMedarbejdereCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: udlejedeMIdentifier, for: indexPath) as? UdlejedeMedarbejdereCollectionViewCell
            cell?.layer.borderWidth = 1.0
            cell?.layer.borderColor = UIColor.gray.cgColor
            
            if (indexPath.row<VirkSingleton.shared.udlejedeFolk.count) {
            cell?.navnLabel.text = VirkSingleton.shared.udlejedeFolk[indexPath.item].medarbejder.navn
            cell?.lejerLabel.text = VirkSingleton.shared.udlejedeFolk[indexPath.item].indlejer?.virkNavn
            cell?.lejeperiodeLabel.text = "\(VirkSingleton.shared.udlejedeFolk[indexPath.item].startDato) - \(VirkSingleton.shared.udlejedeFolk[indexPath.item].slutDato)"
            }
            return cell!
        } else if collectionView == CollectionView2{
            let cell: LejetArbejdskraftCVCell? = collectionView.dequeueReusableCell(withReuseIdentifier: lejetACVIdentifier, for: indexPath) as? LejetArbejdskraftCVCell
            cell?.layer.borderWidth = 1.0
            cell?.layer.borderColor = UIColor.gray.cgColor
            if (indexPath.row<VirkSingleton.shared.indlejedeFolk.count) {
                cell?.navnLabel.text = VirkSingleton.shared.indlejedeFolk[indexPath.item].medarbejder.navn
                cell?.udlejerLabel.text = VirkSingleton.shared.indlejedeFolk[indexPath.item].udlejer?.virkNavn
                cell?.lejeperiodeLabel.text = "\(VirkSingleton.shared.indlejedeFolk[indexPath.item].startDato) - \(VirkSingleton.shared.indlejedeFolk[indexPath.item].slutDato)"
            }
            return cell!
        } else{
            let cell: AlleMedarbejdereCVCell? = collectionView.dequeueReusableCell(withReuseIdentifier: alleMCVIdentifier, for: indexPath) as? AlleMedarbejdereCVCell
            cell?.layer.borderWidth = 1.0
            cell?.layer.borderColor = UIColor.gray.cgColor
            
            if(VirkSingleton.shared.virksomhed?.medarbejdere.count != nil){
                if indexPath.row<(VirkSingleton.shared.virksomhed?.medarbejdere.count)!{
                    cell?.navnLabel.text = VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].navn
                    cell?.udlejetIPeriodeLabel.text = VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].arbejdsomraade
                    cell?.lejetAfLabel.text = VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].foedselsaar
                    
                //Bug hvis ikke de bliver specificeret
                    cell?.LastImageView.isHidden=true
                    cell?.navnLabel.isHidden = false
                    cell?.lejetAfLabel.isHidden = false
                    cell?.udlejetIPeriodeLabel.isHidden = false
                    
                }
                else{
                    cell?.LastImageView.isHidden = false
                    cell?.navnLabel.isHidden = true
                    cell?.lejetAfLabel.isHidden = true
                    cell?.udlejetIPeriodeLabel.isHidden = true
                }
            }
//            cell?.navnLabel.text = "HEEEEY"
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO mangler at teste for om cellen er den sidste i rækken for så skal man kunne oprette
        
        //Test om det er lejede medarbejdere
        if collectionView == CollectionView3 {
            let mineMedarbejdereCV = storyboard?.instantiateViewController(withIdentifier: "ValgtMedarbejderView") as? MineMedarbejdere
            if(indexPath.row < (VirkSingleton.shared.virksomhed?.medarbejdere.count)!){
                
                mineMedarbejdereCV?.medarbejder = Medarbejder(navn: (VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].navn)!, id: (VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].id)!, foedselsaar: (VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].foedselsaar)!, arbejdsomraade: (VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].arbejdsomraade)!)
                mineMedarbejdereCV?.loen = VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].loen
                mineMedarbejdereCV?.kommentar = VirkSingleton.shared.virksomhed?.medarbejdere[indexPath.item].kommentar
            }
            self.navigationController?.pushViewController(mineMedarbejdereCV!, animated: true)
        }
            //Ellers vælg den for egne medarbejdere
            //Gælder begge de andre collections
        else {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "IndgaaedeAftalerView") as? IndgaaedeAftaler

        self.navigationController?.pushViewController(viewController!, animated: true)
        }
    }
}
    
    


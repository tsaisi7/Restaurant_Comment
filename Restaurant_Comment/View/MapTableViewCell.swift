//
//  MapTableViewCell.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/18.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet var mapView: MKMapView!{
        didSet{
            mapView.layer.cornerRadius = 15
        }
    }
    
    func configure(location: String){
        let geoCoder = CLGeocoder()
        print(location)
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let placemarks = placemarks{
                let placemark = placemarks[0]
                let annotaion = MKPointAnnotation()
                if let location = placemark.location{
                    annotaion.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotaion)
                    let region = MKCoordinateRegion(center: annotaion.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

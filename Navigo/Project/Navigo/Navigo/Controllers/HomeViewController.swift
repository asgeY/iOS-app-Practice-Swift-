//
//  HomeViewController.swift
//  Navigo
//
//  Created by Anik on 12/7/19.
//  Copyright © 2019 A7Studio. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import Panels
import UPCarouselFlowLayout
import CoreLocation
import GoogleMaps
import Alamofire

enum RideCompany : Int {
    case taxi = 0
    case ridy = 1
    case autoM = 2
    case none = 3
}

class HomeViewController: UIViewController, SideMenuItemContent, UITextFieldDelegate, VisitPlaceDelegate, VisitNearByPlaceDelegate, OnTripDelegate {
    
    enum ShowingPanel {
        case nearby
        case ride
        case onTrip
    }
    
    enum ShowingRide : Int {
        case car = 0
        case ride = 1
        case publicTrasport = 2
        case none = 3
    }
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            print("current page set: \(self.currentPage)")
            if places.count > 0 {
                places[self.currentPage].isShowing = true
                placesMarker[self.currentPage].icon = UIImage(named: "resturent_marker")
                self.searchCollectionView.reloadData()
                if previousPage != -1 {
                    places[self.previousPage].isShowing = false
                    mapView.animate(to: GMSCameraPosition(latitude: places[self.currentPage].location.coordinate.latitude, longitude: places[self.currentPage].location.coordinate.longitude, zoom: 16.0))
                    //let marker = placesMarker[self.currentPage]
                    placesMarker[self.previousPage].icon = UIImage(named: "unselected_marker")
                }
                previousPage = self.currentPage
            }
        }
    }
    
    var previousPage: Int = -1;
    
    fileprivate var pageSize: CGSize {
        let layout = self.searchCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    var places: [PlacesEntity] = []
    
    var placesMarker: [GMSMarker] = []

    var nowShowingPanel: ShowingPanel = .nearby
    var nowShowingRide: ShowingRide = .none
    var nowRideCompay: RideCompany = .none
    
    @IBOutlet weak var searchTextCrossButton: UIButton!
    @IBOutlet weak var searchResultView: UIView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var topView: RoundedViewWithShadow!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rideShareMultiColorView: RoundedCornerView!
    @IBOutlet weak var rideShareView: UIView!
    @IBOutlet weak var rideShareHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var rideShareViewHeightConstraint: NSLayoutConstraint!
    //ride option
    @IBOutlet weak var carView: RoundedCornerView!
    @IBOutlet weak var rideView: RoundedCornerView!
    @IBOutlet weak var publicTrasportView: RoundedCornerView!
    //sharing option
    @IBOutlet weak var taxiView: RoundedCornerView!
    @IBOutlet weak var ridyView: RoundedCornerView!
    @IBOutlet weak var autoMView: RoundedCornerView!
    
    @IBOutlet weak var callButton: UIButton!
    
    
    @IBOutlet weak var driverMultiColorView: RoundedCornerView!
    @IBOutlet weak var rideAndDriverView: UIView!
    @IBOutlet weak var driverViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var driverArrivalTimeLabel: UILabel!
    
    
    @IBOutlet weak var sourceToDestinationView: UIView!
    @IBOutlet weak var destinationLabel: UILabel!
    
    
    lazy var panelManager = Panels(target: self)
    var panelConfiguration = PanelConfiguration(size: .fullScreen)
    var panel = UIStoryboard.instantiatePanel(identifier: "Nearby") as! Nearby
    var panelForOnTrip = UIStoryboard.instantiatePanel(identifier: "Home") as! OnTripViewController
    
    var selectedPlace: PlacesEntity?
    
    var driverPriceAndRatingView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentPage = 0
        searchTextCrossButton.isHidden = true
        searchTextField.delegate = self
        setupPanelView()
        setupRideViewListener()
        //setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let camera = GMSCameraPosition.camera(withLatitude: 51.494379, longitude: -0.2103103, zoom: 14.0)
        mapView.camera = camera
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }

    }
    
    fileprivate func setupLayout() {
        let layout = self.searchCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 200)
    }
    
    override func viewDidLayoutSubviews() {
        rideShareMultiColorView.topLeft = true
        rideShareMultiColorView.topRight = true
        
        driverMultiColorView.topLeft = true
        driverMultiColorView.topRight = true
    }
    
    func setupRideViewListener() {
        let carGesture = UITapGestureRecognizer(target: self, action:  #selector(self.ownCarSelected))
        carView.addGestureRecognizer(carGesture)
        
        let rideGesture = UITapGestureRecognizer(target: self, action:  #selector(self.rideShareSelected))
        rideView.addGestureRecognizer(rideGesture)
        
        let tranportGesture = UITapGestureRecognizer(target: self, action:  #selector(self.publicTransportSelected))
        publicTrasportView.addGestureRecognizer(tranportGesture)
        
        
        let taxiGesture = UITapGestureRecognizer(target: self, action:  #selector(self.taxiSelected))
        taxiView.addGestureRecognizer(taxiGesture)
        
        let ridyGesture = UITapGestureRecognizer(target: self, action:  #selector(self.ridySelected))
        ridyView.addGestureRecognizer(ridyGesture)
        
        let autoMGesture = UITapGestureRecognizer(target: self, action:  #selector(self.autoMSelected))
        autoMView.addGestureRecognizer(autoMGesture)
    }
    
    @objc func ownCarSelected() {
        print("car selected")
        nowShowingRide = .car
        carView.backgroundColor = ColorUtils.hexStringToUIColor(hex: "576276")
        updateRideOptionView()
        callButton.setTitle("START", for: .normal)
        callButton.isEnabled = true
        callButton.backgroundColor = ColorUtils.hexStringToUIColor(hex: "576276")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.rideShareHeightContraint.constant = 248
                self.rideShareViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        
        mapView.clear()
        showPlaceInMap(place: selectedPlace!)
        showProfileAvatarInMap()
        focusUserOnMap()
        
        //showDirectionBetweenTwoLocation(source: userLocation, destination: (selectedPlace?.location.coordinate)!)
        //directionBetweenLocation(sourceLocation: userLocation, destinationLocation: (selectedPlace?.location.coordinate)!)
    }
    
    @objc func rideShareSelected() {
        print("ride share selected")
        nowShowingRide = .ride
        rideView.backgroundColor = ColorUtils.hexStringToUIColor(hex: "576276")
        updateRideOptionView()
        
        callButton.backgroundColor = ColorUtils.hexStringToUIColor(hex: "576276")
        callButton.isEnabled = false
        updateRideComapnyView()
        focusUserOnMap()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.rideShareHeightContraint.constant = 404
                self.rideShareViewHeightConstraint.constant = 156
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func publicTransportSelected() {
        print("public transport selected")
        nowShowingRide = .publicTrasport
        publicTrasportView.backgroundColor = ColorUtils.hexStringToUIColor(hex: "576276")
        updateRideOptionView()
        callButton.setTitle("START", for: .normal)
        callButton.isEnabled = true
        callButton.backgroundColor = ColorUtils.hexStringToUIColor(hex: "576276")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.rideShareHeightContraint.constant = 248
                self.rideShareViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        mapView.clear()
        showPlaceInMap(place: selectedPlace!)
        showProfileAvatarInMap()
        focusUserOnMap()
    }
    
    let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.4876549, longitude: -0.2217534)
    
    func focusUserOnMap() {
        //51.4876549, -0.2217534
        mapView.animate(to: GMSCameraPosition(latitude: userLocation.latitude, longitude: userLocation.longitude, zoom: 16.0))
    }
    
    @objc func taxiSelected() {
        print("car selected")
        nowRideCompay = .taxi
        updateRideComapnyView()
        taxiView.backgroundColor = ColorUtils.hexStringToUIColor(hex: "FFC400")
        callButton.backgroundColor = ColorUtils.hexStringToUIColor(hex: "FFC400")
        callButton.setTitle("CALL TAXI", for: .normal)
        callButton.isEnabled = true
        //show taxis
        mapView.clear()
        showPlaceInMap(place: selectedPlace!)
        showProfileAvatarInMap()
        showSelectedRide(company: .taxi)
        focusUserOnMap()
        //updateRideOptionView()
    }
    
    func showSelectedRide(company: RideCompany) {
        DispatchQueue.global(qos: .userInitiated).async {
            RideData.shared.getRides(company: company) { rides in
                DispatchQueue.main.async {
                    for ride in rides {
                        let car = self.addMarkerToMap(title: ride.title, snippet: "", location: ride.location, markerImageName: ride.markerImagesName)
                        car.rotation = ride.rotation
                        car.map = self.mapView
                    }
                }
            }
        }
    }
    
    @objc func ridySelected() {
        print("ride share selected")
        nowRideCompay = .ridy
        updateRideComapnyView()
        ridyView.backgroundColor = ColorUtils.hexStringToUIColor(hex: "D461EE")
        callButton.backgroundColor = ColorUtils.hexStringToUIColor(hex: "D461EE")
        callButton.setTitle("CALL RIDY", for: .normal)
        callButton.isEnabled = true
        //show ridy cars
        mapView.clear()
        showPlaceInMap(place: selectedPlace!)
        showProfileAvatarInMap()
        showSelectedRide(company: .ridy)
        focusUserOnMap()
        //updateRideOptionView()
    }
    
    @objc func autoMSelected() {
        print("public transport selected")
        nowRideCompay = .autoM
        updateRideComapnyView()
        autoMView.backgroundColor = ColorUtils.hexStringToUIColor(hex: "00C3EE")
        callButton.backgroundColor = ColorUtils.hexStringToUIColor(hex: "00C3EE")
        callButton.setTitle("CALL AutoM", for: .normal)
        callButton.isEnabled = true
        //show autoM cars
        mapView.clear()
        showPlaceInMap(place: selectedPlace!)
        showProfileAvatarInMap()
        showSelectedRide(company: .autoM)
        focusUserOnMap()
        //updateRideOptionView()
    }
    
    func updateRideComapnyView() {
        let rideCompanyList = [taxiView, ridyView, autoMView]
        for ride in rideCompanyList {
            ride?.backgroundColor = ColorUtils.hexStringToUIColor(hex: "454B63")
        }
    }
    
    @IBAction func callButtonClicked(_ sender: Any) {
        print("call button clicked. \(nowShowingRide.rawValue)")
        if nowShowingRide == .ride {
            print("ride selected \(nowRideCompay.rawValue)")
            //hide ride button
            //show driver view
            //rideShareView.isHidden = true
            driverViewHeightConstraint.constant = 0
            rideAndDriverView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                UIView.animate(withDuration: 0.25, animations: {
                    self.rideShareHeightContraint.constant = 0
                    self.driverViewHeightConstraint.constant = 304
                    self.view.layoutIfNeeded()
                    self.rideShareView.isHidden = true
                    self.driverArrivalTimeRemainingCounter = 8
                })
            }
            //show driver marker on map
            mapView.clear()
            showPlaceInMap(place: selectedPlace!)
            showProfileAvatarInMap()
            focusUserOnMap()
            DispatchQueue.global(qos: .userInitiated).async {
                RideData.shared.getSelectedRide(company: self.nowRideCompay) { ride in
                    DispatchQueue.main.async {
                        let car = self.addMarkerToMap(title: ride.title, snippet: "", location: ride.location, markerImageName: ride.markerImagesName)
                        car.rotation = ride.rotation
                        car.map = self.mapView
                    }
                }
            }
            // show driver to user route on map
            //showDirectionBetweenTwoLocation(source: userLocation, destination: CLLocationCoordinate2D(latitude: 51.486378, longitude: -0.224088))
          //  directionBetweenLocation(sourceLocation: userLocation, destinationLocation: CLLocationCoordinate2D(latitude: 51.486378, longitude: -0.224088))
            startDriverArrivalTimer()
            
        }
    }
    
    //MARK: Driver
    var driverArrivalTimeRemainingCounter = 8
    var timerForDriver = Timer()
    
    fileprivate func startDriverArrivalTimer() {
        timerForDriver.invalidate() // just in case this button is tapped multiple times
        // start the timer
        timerForDriver = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(driverTimerAction), userInfo: nil, repeats: true)
    }
    
    @objc func driverTimerAction() {
        if driverArrivalTimeRemainingCounter > 0 {
            driverArrivalTimeRemainingCounter -= 1
            driverArrivalTimeLabel.text = "\(driverArrivalTimeRemainingCounter) min away"
        } else {
            timerForDriver.invalidate()
            //show onTrip view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                [weak self] in
                self?.nowShowingPanel = .onTrip
                self?.panelForOnTrip.tripTimeRemainingCounter = 80
                self?.panelForOnTrip.onTripDelegate = self
                self?.panelManager.show(panel: self!.panelForOnTrip, config: self!.panelConfiguration)
                self?.panelManager.expandPanel()
                self?.panelManager.collapsePanel()
            }
            //hide driver view
            hideDriverView()
        }
        
    }
    
    fileprivate func hideDriverView() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.driverViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.rideAndDriverView.isHidden = true
            })
        }
    }
    
    @IBAction func cancelRideButtonClicked(_ sender: Any) {
        timerForDriver.invalidate()
        hideDriverView()
        rideShareView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.rideShareHeightContraint.constant = 404
                self.rideAndDriverView.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func tripFinished() {
        if nowShowingPanel == .onTrip {
            if self.panelManager.isExpanded {
                self.mapTopConstraint.constant = -44
            }
            panelManager.dismiss(completion: {
                self.showDriverRatingDialog(onView: self.view)
                //self.nowShowingPanel = .nearby
                //self.setupPanelView()
            })
        } else {
            panelManager.show(panel: panel, config: panelConfiguration)
        }
    }
    
    func updateRideOptionView() {
        var rideList = [carView, rideView, publicTrasportView]
        rideList.remove(at: nowShowingRide.rawValue)
        for ride in rideList {
            ride?.backgroundColor = ColorUtils.hexStringToUIColor(hex: "454B63")
        }
    }
    
    func setupPanelView() {
        mapView.clear()
        panelConfiguration.enclosedNavigationBar = false
        panelManager.delegate = self
        panel.placeDelegate = self
        panelManager.show(panel: panel, config: panelConfiguration)
        
        searchTextField.isHidden = false
        searchTextCrossButton.isHidden = false
        //show source to destination View
        sourceToDestinationView.isHidden = true
        destinationLabel.text = ""
//        nowShowingPanel = .onTrip
//        self.panelForOnTrip.tripTimeRemainingCounter = 121
//        self.panelForOnTrip.onTripDelegate = self
//        self.panelManager.show(panel: self.panelForOnTrip, config: self.panelConfiguration)
    }

    @IBAction func menuButtonClicked(_ sender: Any) {
        showSideMenu()
    }
    
    //MARK: Search
    
    @IBAction func searchDeleteButtonClicked(_ sender: Any) {
        searchTextCrossButton.isHidden = true
        searchTextField.text = ""
        searchResultView.isHidden = true
        if nowShowingPanel == .onTrip {
            panelManager.dismiss(completion: {
                self.nowShowingPanel = .nearby
                self.setupPanelView()
            })
        } else {
            panelManager.show(panel: panel, config: panelConfiguration)
        }

    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if nowShowingPanel == .nearby {
            panelManager.dismiss()
        } else if nowShowingPanel == .ride {
            rideShareView.isHidden = true
        }
        
        searchTextCrossButton.isHidden = false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        DispatchQueue.global(qos: .userInitiated).async {
            PlaceData.shared.getPlaces() { places in
                DispatchQueue.main.async {
                    self.places = places
                    self.searchResultView.isHidden = false
                    self.searchCollectionView.reloadData()
                    self.updateMapView()
                }
            }
        }
        return true
    }
    
    func updateMapView() {
        if places.count > 0 {
            let firstPlace = places[0]
            let camera = GMSCameraPosition.camera(withLatitude: firstPlace.location.coordinate.latitude, longitude: firstPlace.location.coordinate.longitude, zoom: 16.0)
            mapView.camera = camera
            for place in places {
                let marker = addMarkerToMap(title: place.name, snippet: "", location: CLLocationCoordinate2D(latitude: place.location.coordinate.latitude, longitude: place.location.coordinate.longitude), markerImageName: "unselected_marker")
                marker.map = mapView
                placesMarker.append(marker)
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.searchCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    func goToPlace(place: PlacesEntity) {
        print("go there button clicked")
        //hide collection view of resturent
        searchResultView.isHidden = true
        //hide/disable search bar textfield
        searchTextField.isHidden = true
        searchTextCrossButton.isHidden = true
        //show source to destination View
        sourceToDestinationView.isHidden = false
        destinationLabel.text = place.name
        //show only the place selected in map
        selectedPlace = place
        showPlaceInMap(place: place)
        //show profile avatar
        showProfileAvatarInMap()
        //show select ride option
        nowShowingPanel = .ride
        showRideChooserView()
    }
    
    func goToNearByPlace(place: PlacesEntity) {
        panelManager.dismiss()
        nowShowingPanel = .ride
        selectedPlace = place
        updateSearchView()
        print("go there button clicked")
        //hide/disable search bar textfield
        searchTextField.isHidden = true
        searchTextCrossButton.isHidden = true
        //show source to destination View
        sourceToDestinationView.isHidden = false
        destinationLabel.text = place.name
        //show the place selected on map
        showPlaceInMap(place: place)
        //show profile avatar
        showProfileAvatarInMap()
        // show select ride option
        showRideChooserView()
    }
    
    func showPlaceInMap(place: PlacesEntity) {
        mapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: place.location.coordinate.latitude, longitude: place.location.coordinate.longitude, zoom: 16.0)
        mapView.camera = camera
        let marker = addMarkerToMap(title: place.name, snippet: "", location: CLLocationCoordinate2D(latitude: place.location.coordinate.latitude, longitude: place.location.coordinate.longitude), markerImageName: "resturent_marker")
        marker.map = mapView
    }
    
    func showProfileAvatarInMap() {
        let marker = addMarkerToMap(title: "You", snippet: "", location: CLLocationCoordinate2D(latitude: 51.4876549, longitude: -0.2217534), markerImageName: "avatar_icon")
        marker.map = mapView
    }
    
    func updateSearchView() {
        self.view.backgroundColor = .white
        topView.isHidden = false
        topView.showShadow()
    }
    
    func showRideChooserView(){
        self.mapTopConstraint.constant = -44
        rideShareView.isHidden = false
        self.rideShareHeightContraint.constant = 0
        self.rideShareViewHeightConstraint.constant = 0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.rideShareHeightContraint.constant = 248
                self.rideShareViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        //rideShareHeightContraint.constant = 172
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            [weak self] in
            self?.panelManager.show(panel: self!.panelForRideChooser, config: self!.panelConfigurationHalf)
        }
 */
        
    }
    
    func addMarkerToMap(title: String, snippet: String, location: CLLocationCoordinate2D, markerImageName: String) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        marker.title = title
        marker.snippet = snippet
        marker.icon = UIImage(named: markerImageName)
        return marker
    }
    
    fileprivate func directionBetweenLocation(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        let origin = "\(sourceLocation.latitude),\(sourceLocation.longitude)"
        let destination = "\(destinationLocation.latitude),\(destinationLocation.longitude)"
        
        //let url = "http://router.project-osrm.org/route/v1/driving/\(origin);\(destination)?overview=false"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyA-2M_CQqkeHa0LC-Y6P5GgcJNlvXbY7H8"
        
        AF.request(url).responseJSON { response in
            print(response.request!)  // original URL request
            print(response.response!) // HTTP URL response
            print(response.data!)     // server data
            print(response.result)   // result of response serialization
            /*
            do {
                let json = try JSON(data: response.data!)
                let routes = json["routes"].arrayValue
                
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.map = self.MapView
                }
            }
            catch {
                print("ERROR: not working")
            }
 */
        }
    }
    
    private func drawPath(with points : String){
        
        DispatchQueue.main.async {
            
            let path = GMSPath(fromEncodedPath: points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .red
            polyline.map = self.mapView
            
        }
    }
    
}

extension HomeViewController: PanelNotifications {
    func panelDidPresented() {
        //print("Panel is presented")
        if self.nowShowingPanel == .nearby {
            panel.updateTopView(isBottom: false)
            updateSearchView()
        } else if self.nowShowingPanel == .onTrip {
            panelForOnTrip.updateTopView(isBottom: false)
        }
    }
    
    func panelDidCollapse() {
        //print("Panel did collapse")
        if self.nowShowingPanel == .nearby {
            panel.updateTopView(isBottom: false)
            updateSearchView()
            self.mapTopConstraint.constant = -44
        } else if self.nowShowingPanel == .onTrip {
            self.mapTopConstraint.constant = -44
            panelForOnTrip.updateTopView(isBottom: false)
        }
    }
    
    func panelDidOpen() {
        //print("Panel did open")
        if self.nowShowingPanel == .nearby {
            panel.updateTopView(isBottom: true)
            topView.isHidden = true
            topView.hideShadow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                [weak self] in
                self?.view.backgroundColor = self?.panel.view.backgroundColor
                self?.mapTopConstraint.constant = 0
            }
        } else if self.nowShowingPanel == .onTrip {
            self.mapTopConstraint.constant = 0
            self.view.backgroundColor = self.panelForOnTrip.view.backgroundColor
            panelForOnTrip.updateTopView(isBottom: true)
        }
    }
}

extension HomeViewController {
    func showDriverRatingDialog(onView : UIView) {
        let sView = UIView.init(frame: onView.bounds)
        sView.backgroundColor = UIColor(white: 1.0, alpha: 0.72)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //sView.addSubview(blurEffectView)
        
        let sv = DriverRatingView(frame: onView.bounds)
        sv.center = sView.center
        sView.addSubview(sv)
        onView.addSubview(sView)
        
        driverPriceAndRatingView = sView
        
        sv.submitButton.addTarget(self, action: #selector(submitClicked(sender:)), for: .touchUpInside)
    }
    
    @objc func submitClicked(sender: UIButton!) {
        DispatchQueue.main.async {
            self.driverPriceAndRatingView?.removeFromSuperview()
            self.driverPriceAndRatingView = nil
            
            self.nowShowingPanel = .nearby
            self.setupPanelView()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "places", for: indexPath) as! PlacesCell
        let place = places[indexPath.row]
        cell.imageView.image = UIImage(named: place.imageName)
        cell.nameLabel.text = place.name
        cell.infoLabel.text = "\(place.distance)mi, \(place.rating) stars"
        
        if places[indexPath.row].isShowing {
            cell.infoView.backgroundColor = ColorUtils.hexStringToUIColor(hex: "#3ACCE1")
        } else {
            cell.infoView.backgroundColor = ColorUtils.hexStringToUIColor(hex: "#353A50")
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collection view item selected")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Nearby", bundle: nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "placeDetailView") as! PlaceDetailViewController
        let place = places[indexPath.row]
        detailViewController.place = place
        detailViewController.placeDelegate = self
        self.present(detailViewController, animated: true, completion: nil)
        //self.show(detailViewController, sender: nil)
    }
}

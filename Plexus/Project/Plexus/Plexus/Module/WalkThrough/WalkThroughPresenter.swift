//
//  WalkThroughPresenter.swift
//  Plexus
//
//  Created Anik on 16/8/19.
//  Copyright © 2019 A7Studio. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import UIKit

class WalkThroughPresenter: WalkThroughPresenterProtocol {

    weak private var view: WalkThroughViewProtocol?
    var interactor: WalkThroughInteractorProtocol?
    private let router: WalkThroughWireframeProtocol

    init(interface: WalkThroughViewProtocol, interactor: WalkThroughInteractorProtocol?, router: WalkThroughWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

}

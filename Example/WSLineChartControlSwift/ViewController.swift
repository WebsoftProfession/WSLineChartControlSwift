//
//  ViewController.swift
//  WSLineChartControlSwift
//
//  Created by WebsoftProfession on 03/15/2023.
//  Copyright (c) 2023 WebsoftProfession. All rights reserved.
//

import UIKit
import WSLineChartControlSwift

class ViewController: UIViewController {
    
    
    @IBOutlet weak var chartControl: WSLineChartControl!
    
    var popupView: PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        popupView = Bundle.main.loadNibNamed("PopupView", owner: self, options: nil)![0] as? PopupView
        
        chartControl.chartMode = .stroke
        chartControl.chartStyle = .linear
        chartControl.axisColor = .gray
        chartControl.axisValueColor = .gray
        
        chartControl.clipsToBounds = true
        chartControl.layer.cornerRadius = 5.0
        
        chartControl.delegate = self
        
//        chartControl.dataset = [WSChartDatasetModel.init(values: [WSValueDataset.init(xValue: 0, yValue: 3),
//                                                                  WSValueDataset.init(xValue: 1, yValue: 25),
//                                                                  WSValueDataset.init(xValue: 2, yValue: 7),
//                                                                  WSValueDataset.init(xValue: 3, yValue: 9),
//                                                                  WSValueDataset.init(xValue: 4, yValue: 16),
//                                                                  WSValueDataset.init(xValue: 5, yValue: 19),
//                                                                  WSValueDataset.init(xValue: 6, yValue: 21)], color: .systemRed, gradientColor: .init(startColor: .systemRed, endColor: .systemRed)),
//                                WSChartDatasetModel.init(values: [WSValueDataset.init(xValue: 0, yValue: 7),
//                                                                  WSValueDataset.init(xValue: 1, yValue: 20),
//                                                                  WSValueDataset.init(xValue: 2, yValue: 9),
//                                                                  WSValueDataset.init(xValue: 3, yValue: 11),
//                                                                  WSValueDataset.init(xValue: 4, yValue: 17),
//                                                                  WSValueDataset.init(xValue: 5, yValue: 26),
//                                                                  WSValueDataset.init(xValue: 6, yValue: 50)], color: .systemGreen, gradientColor: .init(startColor: .systemGreen, endColor: .systemGreen))]
        
        
        chartControl.dataset = [WSChartDatasetModel.init(values: [WSLabelDataset.init(xValue: "Jan", yValue: 3),
                                                                  WSLabelDataset.init(xValue: "Feb", yValue: 25),
                                                                  WSLabelDataset.init(xValue: "Mar", yValue: 7),
                                                                  WSLabelDataset.init(xValue: "Apr", yValue: 10),
                                                                  WSLabelDataset.init(xValue: "May", yValue: 15),
                                                                  WSLabelDataset.init(xValue: "Jun", yValue: 17),
                                                                  WSLabelDataset.init(xValue: "Jul", yValue: 12),
                                                                  WSLabelDataset.init(xValue: "Aug", yValue: 7),
                                                                  WSLabelDataset.init(xValue: "Sep", yValue: 18),
                                                                  WSLabelDataset.init(xValue: "Oct", yValue: 19),
                                                                  WSLabelDataset.init(xValue: "Nov", yValue: 27),
                                                                  WSLabelDataset.init(xValue: "Dec", yValue: 30)], color: .systemGreen, gradientColor: .init(startColor: .systemGreen, endColor: .systemGreen)),

                                WSChartDatasetModel.init(values: [WSLabelDataset.init(xValue: "Jan", yValue: 1),
                                                                  WSLabelDataset.init(xValue: "Feb", yValue: 5),
                                                                  WSLabelDataset.init(xValue: "Mar", yValue: 7),
                                                                  WSLabelDataset.init(xValue: "Apr", yValue: 9),
                                                                  WSLabelDataset.init(xValue: "May", yValue: 11),
                                                                  WSLabelDataset.init(xValue: "Jun", yValue: 8),
                                                                  WSLabelDataset.init(xValue: "Jul", yValue: 12),
                                                                  WSLabelDataset.init(xValue: "Aug", yValue: 17),
                                                                  WSLabelDataset.init(xValue: "Sep", yValue: 15),
                                                                  WSLabelDataset.init(xValue: "Oct", yValue: 14),
                                                                  WSLabelDataset.init(xValue: "Nov", yValue: 10),
                                                                  WSLabelDataset.init(xValue: "Dec", yValue: 5)], color: .systemRed, gradientColor: .init(startColor: .systemRed, endColor: .systemRed))]
        
        chartControl.loadLineChart()
        
        
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        chartControl.loadLineChart()
    }

}


extension ViewController: WSLineChartControlDelegate {
    func viewForSelectedDataset(datasetIndex: Int, dataIndex: Int) -> UIView? {
        
        if datasetIndex == 0 {
            popupView?.lblTitle.text = "Income"
        }
        else {
            popupView?.lblTitle.text = "Expense"
        }
        
        popupView?.lblSubtitle.text = "\(self.chartControl.dataset[datasetIndex].labelsDataset[dataIndex].xValue) : \(Int(self.chartControl.dataset[datasetIndex].labelsDataset[dataIndex].yValue))%"
        
        popupView?.layer.cornerRadius = 5.0
        popupView?.layer.masksToBounds = false
        popupView?.layer.shadowColor = self.chartControl.dataset[datasetIndex].color.cgColor
        popupView?.layer.shadowOpacity = 0.5
         
        popupView?.layer.shadowRadius = 5.0
        
        popupView?.layer.shadowPath = UIBezierPath(rect: popupView?.bounds ?? .zero).cgPath
        popupView?.layer.shouldRasterize = true
        popupView?.layer.rasterizationScale = 1
        
        return popupView
    }
    
}


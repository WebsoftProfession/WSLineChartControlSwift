//
//  WSLineChartModel.swift
//  DSChartControl
//
//  Created by WebsoftProfession on 17/02/23.
//

import Foundation
import UIKit


public struct WSChartDatasetModel {
    
    public let valuesDataset: [WSValueDataset]
    public let color: UIColor
    public let gradientColor: WSGradientValues?
    public let labelsDataset: [WSLabelDataset]
    
    
    
    
    public init(values:[WSValueDataset], color: UIColor, gradientColor: WSGradientValues = WSGradientValues(startColor: .gray, endColor: .darkGray)){
        self.valuesDataset = values
        self.color = color
        self.gradientColor = gradientColor
        self.labelsDataset = []
    }
    
    public init(values:[WSLabelDataset], color: UIColor, gradientColor: WSGradientValues = WSGradientValues(startColor: .gray, endColor: .darkGray)){
        self.labelsDataset = values
        self.color = color
        self.gradientColor = gradientColor
        self.valuesDataset = []
    }
}

public struct WSValueDataset {
    public let xValue: Float
    public let yValue: Float
    public init(xValue: Float, yValue: Float) {
        self.xValue = xValue
        self.yValue = yValue
    }
}

public struct WSLabelDataset {
    public let xValue: String
    public let yValue: Float
    public init(xValue: String, yValue: Float) {
        self.xValue = xValue
        self.yValue = yValue
    }
}

public struct WSGradientValues {
    public let startColor: UIColor
    public let endColor: UIColor
    
    public init(startColor: UIColor, endColor: UIColor) {
        self.startColor = startColor
        self.endColor = endColor
    }
}


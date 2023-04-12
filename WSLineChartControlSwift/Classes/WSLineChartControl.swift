//
//  DSChartPanel.swift
//  DSChartControl
//
//  Created by WebsoftProfession on 21/12/22.
//

import UIKit


public protocol WSLineChartControlDelegate {
    func viewForSelectedDataset(datasetIndex: Int, dataIndex: Int) -> UIView?
}



public enum WSLineChartStyle: Int {
    case linear = 0
    case curve = 1
}

public enum WSLineChartDrawMode: Int {
    case stroke = 0
    case fill = 1
    case strokeFill = 2
    case fillGradient = 3
    case strokeFillGradient = 4
    case none
}

enum WSLineChartVariationMode: Int {
    case automatic = 0
    case manual = 1
}

public enum WSChartXAxisMode: Int {
    case value = 0
    case timeInterval = 1
}




public class WSLineChartControl: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     */
    
    private var xPath: UIBezierPath?
    private var yPath: UIBezierPath?
    
    private var xBasePath: UIBezierPath?
    private var yBasePath: UIBezierPath?
    
    
    private var graphPath: UIBezierPath?
    
    private var xInsetValue = 30.0
    private var yInsetValue = 30.0
    
    private var xRightInsetValue = 20.0
    private var yTopInsetValue = 20.0
    
    
    private var maxRatioX = 0.0
    private var maxRatioY = 0.0
    
    private var colorAlpha: Float = 1.0
    
    
    var xVariation = 1
    var yVariation = 1
    
    public var axisColor: UIColor = .black
    public var axisValueColor: UIColor = .black
    public var chartStyle:WSLineChartStyle = .linear
    public var chartMode:WSLineChartDrawMode = .stroke
    public var delegate: WSLineChartControlDelegate?
    var chartVariationMode:WSLineChartVariationMode = .automatic
    public var axisValueFont: UIFont = .systemFont(ofSize: 12)
    
    public var dataset: [WSChartDatasetModel] = []
    private var isReload: Bool = true
    
    private var popupView: UIView?
    private var dotPaths = [DotPathModel]()
    
    public override func draw(_ rect: CGRect) {
        // Drawing code

        if (dataset.count == 0) {
            return
        }
        
        var maxXValue:Float = 0.0
        var maxYValue:Float = 0.0
        var isLabelDataSet = false
        var isDrawVertical = false
        
        var maxXValueString = ""
        
        
        
        for data in dataset {
            
            if data.valuesDataset.count != 0 {
                if let maxX = data.valuesDataset.max(by: { $0.xValue < $1.xValue }) {
                    if maxX.xValue > maxXValue {
                        maxXValue = maxX.xValue
                    }
                }
                
                if let maxX = data.valuesDataset.max(by: { "\($0.xValue)".count < "\($1.xValue)".count }) {
                    let value = Int(maxX.xValue)
                    if "\(value)".count > maxXValueString.count {
                        maxXValueString = "\(value)"
                    }
                }
                
            }
            else if data.labelsDataset.count != 0 {
                maxXValue = Float(data.labelsDataset.count-1)
                isLabelDataSet = true
                if let maxX = data.labelsDataset.max(by: { $0.xValue.count < $1.xValue.count }) {
                    if maxX.xValue.count > maxXValueString.count {
                        maxXValueString = maxX.xValue
                    }
                    
                }
            }
            
            if let maxY = data.valuesDataset.max(by: { $0.yValue < $1.yValue }) {
                if maxY.yValue > maxYValue {
                    maxYValue = maxY.yValue
                }
            }
            
            if let maxY = data.labelsDataset.max(by: { $0.yValue < $1.yValue }) {
                if maxY.yValue > maxYValue {
                    maxYValue = maxY.yValue
                }
            }
            
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        /// Set line break mode
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.center
        var attributes: [NSAttributedString.Key : Any]
        
        attributes = [
            NSAttributedString.Key.font: axisValueFont,
            NSAttributedString.Key.foregroundColor: axisValueColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        if maxXValueString.count > 3 || maxXValue > 10 {
            isDrawVertical = true
            let textSize: CGSize = maxXValueString.size(withAttributes: attributes)
            
            yInsetValue = textSize.width + 15
        }
        
        let textSize: CGSize = "\(maxYValue)".size(withAttributes: attributes)
        xInsetValue = textSize.width
        
        if maxXValue > 10 {
            if isLabelDataSet {
                xVariation = 1
            }
            else{
                maxXValue = maxXValue / 10
                xVariation = Int(ceil(maxXValue))
                maxXValue = 10
            }
        }
        
        if maxYValue > 10 {
            maxYValue = maxYValue / 10
            yVariation = Int(ceil(maxYValue))
            maxYValue = 10
        }
        
        if maxXValue == 0 {
            maxXValue = 10
        }
        
        if maxYValue == 0 {
            maxYValue = 10
        }
        
        
        maxRatioX = (self.bounds.width - (xInsetValue + xRightInsetValue)) / Double(maxXValue)
        maxRatioY = (self.bounds.height - (yInsetValue  + yTopInsetValue)) / Double(maxYValue)

        // X Line Path
        if xBasePath == nil || isReload {
            xBasePath = UIBezierPath.init()
            axisColor.setStroke()
            xBasePath?.lineWidth = 1
            
            xBasePath?.move(to: CGPoint.init(x: xInsetValue, y: rect.height - yInsetValue))
            xBasePath?.addLine(to: CGPoint.init(x: rect.width - xRightInsetValue, y: rect.height - yInsetValue))
            xBasePath?.stroke()
        }
        
        
        // Y Line Path
        if yBasePath == nil || isReload {
            yBasePath = UIBezierPath.init()

            yBasePath?.move(to: CGPoint.init(x: xInsetValue, y: rect.minY + yTopInsetValue))
            yBasePath?.addLine(to: CGPoint.init(x: xInsetValue, y: rect.height - yInsetValue))
            axisColor.setStroke()
            yBasePath?.stroke()
        }
        
        // Draw X Points
        if xPath == nil || isReload {
            
            xPath = UIBezierPath.init()
            xPath?.move(to: CGPoint.init(x: xInsetValue, y: rect.height - yInsetValue))
            
            
            if isDrawVertical {
                (isLabelDataSet ? dataset[0].labelsDataset[0].xValue : "0").drawWithBasePoint(basePoint: .init(x: xInsetValue, y: rect.height - yInsetValue/2), andAngle: -1 * .pi/3, andAttributes: attributes)
            }
            else{
                self.drawTitle( isLabelDataSet ? dataset[0].labelsDataset[0].xValue : "0", with: .systemFont(ofSize: 12), in: CGRect.init(x: xInsetValue - 12 , y: rect.height - yInsetValue + 5, width: 20, height: 20), attributes: attributes)
            }
            
            for value in 1...Int(maxXValue) {
                let path = UIBezierPath.init()
                let pointToMove = CGPoint.init(x: xInsetValue + (maxRatioX * Double(value)), y: rect.height  - yInsetValue)
                path.move(to: pointToMove)
                path.addLine(to: CGPoint.init(x: xInsetValue + (maxRatioX * Double(value)) - 0.5 , y: rect.height  - yInsetValue))
                xPath?.append(path)
                var xLabelString = ""
                if isLabelDataSet {
                    if dataset[0].labelsDataset.count == value {
                        break
                    }
                    xLabelString = dataset[0].labelsDataset[value].xValue
                }
                else{
                    xLabelString = "\(value * xVariation)"
                }
                
                if isDrawVertical {
                    xLabelString.drawWithBasePoint(basePoint: .init(x: pointToMove.x, y: rect.height - yInsetValue/2), andAngle: -1 * .pi/3, andAttributes: attributes)
                }
                else{
                    self.drawTitle(xLabelString, with: self.axisValueFont, in: CGRect.init(x: pointToMove.x - 12 , y: rect.height - yInsetValue + 5, width: 20, height: 20), attributes: attributes)
                }
            }
            self.axisValueColor.setStroke()
            xPath?.lineWidth = 5
            xPath?.stroke()
        }
        
        // Draw Y Points
        if yPath == nil || isReload {
            yPath = UIBezierPath.init()
            yPath?.move(to: CGPoint.init(x: xInsetValue, y: rect.height - yInsetValue))
            
            for value in 1...Int(maxYValue) {
                let path = UIBezierPath.init()
                let pointToMove = CGPoint.init(x: xInsetValue, y: rect.height - ((maxRatioY * Double(value)) + yInsetValue))
                path.move(to: pointToMove)
                path.addLine(to: CGPoint.init(x: xInsetValue, y: rect.height + 0.5 - ((maxRatioY * Double(value)) + yInsetValue)))
                yPath?.append(path)
                self.drawTitle("\(value * yVariation)", with: self.axisValueFont, in: CGRect.init(x: 0 , y: pointToMove.y - 10, width: xInsetValue, height: 20), attributes: attributes)
            }
            self.axisColor.setStroke()
            yPath?.lineWidth = 5
            yPath?.stroke()
        }
        
        // Draw points based on values
        graphPath = UIBezierPath()
        colorAlpha = 1.0 / Float(Double(dataset.count) * 1.2)
        var tempAlpha: Float = 1.0 + colorAlpha
        
        for index in 0..<dataset.count {
            let data = dataset[index]
            var points = convertValueToPoints(data: data)
            
            let path = UIBezierPath()
            path.move(to: CGPoint.init(x: xInsetValue, y: rect.height - yInsetValue))
            points = convertValueToPoints(data: data)
            
            if chartStyle == .linear {
                for point in points {
                    path.addLine(to: point)
                }
            }
            else{
                quadCurvedPath(path: path, withPoints: points)
            }
            
            if chartMode == .fill || chartMode == .strokeFill || chartMode == .fillGradient || chartMode == .strokeFillGradient  {
                path.addLine(to: CGPoint.init(x: path.currentPoint.x, y: CGFloat(rect.maxY - yInsetValue)))
                path.close()
            }
            
            tempAlpha -= colorAlpha
            data.color.withAlphaComponent(CGFloat(tempAlpha)).setStroke()
            data.color.withAlphaComponent(CGFloat(tempAlpha)).setFill()
            path.lineWidth = 2.0
            
            self.drawPath(path: path, startPoint: points[0], gradientColor: data.gradientColor!)
            drawDotPath(points: points, color: data.color, dataSetIndex: index)
        }
        
        isReload = false
    }
    
    private func drawPath(path: UIBezierPath, startPoint: CGPoint = .zero, gradientColor:WSGradientValues){
        switch chartMode {
        case .stroke:
            path.stroke()
        case .fill:
            path.fill()
        case .strokeFill:
            path.stroke()
            path.fill()
        case .none: do {}
        case .fillGradient:
            drawLinearGradient(inside: path, start: startPoint, end: CGPoint.init(x: self.bounds.maxX, y: self.bounds.maxY), colors: [gradientColor.startColor.withAlphaComponent(0.01), gradientColor.endColor])
        case .strokeFillGradient:
            path.stroke()
            drawLinearGradient(inside: path, start: startPoint, end: CGPoint.init(x: self.bounds.maxX, y: self.bounds.maxY), colors: [gradientColor.startColor.withAlphaComponent(0.01), gradientColor.endColor])
        }
    }
    
    
    private func drawDotPath(points: [CGPoint], color: UIColor, dataSetIndex: Int){
        
        for point in points {
            let circlePath = UIBezierPath.init(ovalIn: CGRect.init(x: point.x - 4, y: point.y - 4, width: 8, height: 8))
            let circlePath2 = UIBezierPath.init(ovalIn: CGRect.init(x: point.x - 3, y: point.y - 3, width: 6, height: 6))
            color.withAlphaComponent(0.5).setStroke()
            color.withAlphaComponent(1).setFill()
            
            circlePath.stroke()
            circlePath2.fill()
            
            dotPaths.append(DotPathModel.init(dotBounds: circlePath.bounds, datasetIndex: dataSetIndex, dataIndex: points.firstIndex(of: point) ?? -1))
            
        }
    }
    
    private func drawLinearGradient(inside path:UIBezierPath, start:CGPoint, end:CGPoint, colors:[UIColor])
    {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.saveGState()
        defer { ctx.restoreGState() } // clean up graphics state changes when the method returns
        
        path.addClip() // use the path as the clipping region
        
        let cgColors = colors.map({ $0.cgColor })
        guard let gradient = CGGradient(colorsSpace: nil, colors: cgColors as CFArray, locations: nil)
        else { return }
        
        ctx.drawLinearGradient(gradient, start: start, end: end, options: [])
    }
    
    private func convertValueToPoints(data: WSChartDatasetModel) -> [CGPoint] {
        var points = [CGPoint]()
        
        if data.valuesDataset.count != 0 {
            for index in 0..<data.valuesDataset.count {
                let xPoint = xInsetValue + (maxRatioX / Double(xVariation)) * Double(data.valuesDataset[index].xValue)
                let yPoint = self.bounds.height - (((maxRatioY / Double(yVariation)) * Double(data.valuesDataset[index].yValue)) + yInsetValue)
                points.append(CGPoint.init(x: xPoint, y: yPoint))
            }
        }
        else if data.labelsDataset.count != 0 {
            for index in 0..<data.labelsDataset.count {
                let xPoint = xInsetValue + (maxRatioX / Double(xVariation)) * Double(index)
                let yPoint = self.bounds.height - (((maxRatioY / Double(yVariation)) * Double(data.labelsDataset[index].yValue)) + yInsetValue)
                points.append(CGPoint.init(x: xPoint, y: yPoint))
            }
        }
        
        
        
        return points
    }
    
    private func drawTitle(_ title: String, with font: UIFont?, in contextRect: CGRect, attributes: [NSAttributedString.Key: Any]) {
        let size = title.size(withAttributes: attributes)
        let textRect = CGRect(
            x: contextRect.origin.x + Double(floorf(Float((contextRect.size.width - size.width) / 2))),
            y: contextRect.origin.y + Double(floorf(Float((contextRect.size.height - size.height) / 2))),
            width: size.width,
            height: size.height)
        title.draw(in: textRect, withAttributes: attributes)
    }
    
    
    // Draw smooth curve
    
    private func quadCurvedPath(path: UIBezierPath, withPoints points: [CGPoint]) {
        var p1 = points[0]
        for i in 1..<points.count {
            if i == 1 {
                path.addLine(to: points[0])
            }
            let p2 = points[i]
            let midPoint = midPointForPoints(p1, p2)
            path.addQuadCurve(to: midPoint, controlPoint: controlPointForPoints(midPoint, p1))
            path.addQuadCurve(to: p2, controlPoint: controlPointForPoints(midPoint, p2))
            p1 = p2
        }
    }
    
    private func midPointForPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    private func controlPointForPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        var controlPoint = midPointForPoints(p1, p2)
        let diffY = abs(p2.y - controlPoint.y)

        if p1.y < p2.y {
            controlPoint.y += diffY
        } else if p1.y > p2.y {
            controlPoint.y -= diffY
        }

        return controlPoint
    }
    
    public func loadLineChart(){
        isReload = true
        dotPaths = [DotPathModel]()
        self.setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch = touches.first!
        let location = touch.location(in: self)
        var activeDotPath:DotPathModel? = nil
        let isPathTapped = dotPaths.contains(where: { dotPath in
            activeDotPath = dotPath
            return dotPath.dotBounds.contains(location)
        })
        if isPathTapped {
            
            if popupView != nil {
                popupView?.removeFromSuperview()
            }
            
            
            popupView = self.delegate?.viewForSelectedDataset(datasetIndex: activeDotPath!.datasetIndex, dataIndex: activeDotPath!.dataIndex)
            
            if popupView == nil {
                return
            }
            
            let tempSize = popupView?.frame.size ?? .zero
            
            popupView?.frame = CGRect.init(origin: location, size: .zero)
            
            if (location.x + tempSize.width) > self.frame.size.width && (location.y + tempSize.height) > self.frame.size.height {
                // draw on top left
                self.popupView?.frame = CGRect.init(x: location.x - tempSize.width, y: location.y - tempSize.height, width: tempSize.width, height: tempSize.height)
            }
            else if (location.x + tempSize.width) > self.frame.size.width && (location.y + tempSize.height) < self.frame.size.height {
                // draw left
                self.popupView?.frame = CGRect.init(x: location.x - tempSize.width, y: location.y, width: tempSize.width, height: tempSize.height)
            }
            else if (location.x + tempSize.width) < self.frame.size.width && (location.y + tempSize.height) > self.frame.size.height {
                // draw top
                self.popupView?.frame = CGRect.init(x: location.x, y: location.y - tempSize.width, width: tempSize.width, height: tempSize.height)
            }
            else{
                self.popupView?.frame = CGRect.init(origin: location, size: CGSize.init(width: tempSize.width, height: tempSize.height))
            }
            self.addSubview(popupView!)
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                
            } completion: { completed in
                
            }

            
        }
        else {
            popupView?.removeFromSuperview()
        }
    }
    
    
}

extension String {
    func drawWithBasePoint(basePoint: CGPoint, andAngle angle: CGFloat, andAttributes attributes: [NSAttributedString.Key: Any]) {
        let radius: CGFloat = 0
        let textSize: CGSize = self.size(withAttributes: attributes)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        let t: CGAffineTransform = CGAffineTransform(translationX: basePoint.x, y: basePoint.y)
        let r: CGAffineTransform = CGAffineTransform(rotationAngle: angle)
        context.concatenate(t)
        context.concatenate(r)
        self.draw(at: CGPoint(x: radius-textSize.width/2, y: -textSize.height/2), withAttributes: attributes)
        context.concatenate(r.inverted())
        context.concatenate(t.inverted())
    }
}


fileprivate struct DotPathModel {
    let dotBounds: CGRect
    let datasetIndex: Int
    let dataIndex: Int
}

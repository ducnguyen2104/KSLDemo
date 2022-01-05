//
//  KSYMiscView.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYMiscView: KSYUIView {

    var btn0: UIButton?
    var btn1: UIButton?
    var btn2: UIButton?
    var btn3: UIButton?
    var btn4: UIButton?

    var swBypassRec: UISwitch?
    var lblRecDur: UILabel?
    
    var layerSeg: UISegmentedControl?
    var alphaSl: KSYNameSlider?
    
    var liveSceneSeg: UISegmentedControl?
    var vEncPerfSeg: UISegmentedControl?
    
    var liveScene: KSYLiveScene? {
        get{
            if self.liveSceneSeg?.selectedSegmentIndex == 1 {
                return .showself
            }else{
                return .default
            }
        }
    }
    var vEncPerf: KSYVideoEncodePerformance? {
        get{
            switch self.vEncPerfSeg!.selectedSegmentIndex {
            case 0:
                return .per_LowPower
            case 1:
                return .per_Balance
            case 2:
                return .per_HighPerformance
            default:
                return .per_Balance
            }
        }
    }
    
    var autoReconnect: KSYNameSlider?
    
    private
    var _curBtn: UIButton?
    var _lblScene: UILabel?
    var _lblPerf: UILabel?
    var _lblRec: UILabel?
    
    override init(withParent pView: KSYUIView) {
        super.init(withParent: pView)
        btn0 = addButton(title: "str screenshot as a file")
        btn1 = addButton(title: "str screenshot as a UIImage")
        btn2 = addButton(title: "filter screenshot")
        
        btn3 = addButton(title: "chooseLogo")
        btn4 = addButton(title: "ShootLogo")
        
        _lblRec = addLabel(title: "Bypass recording")
        swBypassRec = addSwitch(on: false)
        lblRecDur = addLabel(title: "0s")
        
        layerSeg = addSegCtrlWithItems(items: ["logo", "Word"])
        alphaSl = addSlider(name: "alpha", from: 0.0, to: 1.0, initV: 1.0)
        
        _lblScene = addLabel(title: "Live scene")
        liveSceneSeg = addSegCtrlWithItems(items: ["default", "Show"])
        _lblPerf = addLabel(title: "Encoding performance")
        vEncPerfSeg = addSegCtrlWithItems(items: ["Low power consumption", "balanced", "high performance"])
        autoReconnect = addSlider(name: "Automatic reconnection times", from: 0.0, to: 10, initV: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutUI() {
        super.layoutUI()
        btnH = 30
        putRow3(subV0: btn0, and: btn1, and: btn2)
        putLabel(lbl: _lblScene!, andView: liveSceneSeg!)
        putLabel(lbl: _lblPerf!, andView: vEncPerfSeg!)
        putRow(subV: [btn4!, btn3!])
        putNarrow(firstV: layerSeg!, andWide: alphaSl!)
        putRow(subV: [_lblRec!, swBypassRec!, lblRecDur!])
        putRow1(subV: autoReconnect)
    }
}

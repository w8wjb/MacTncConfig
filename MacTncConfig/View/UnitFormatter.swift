//
//  VoltageFormatter.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/19/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

class UnitFormatter : Formatter {
    
    let measurementFormatter = MeasurementFormatter()
    
    let unit: Unit
    
    init(unit: Unit) {
        self.unit = unit
        super.init()
        measurementFormatter.unitOptions = .providedUnit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func string(for obj: Any?) -> String? {
        
        guard let value = obj as? NSNumber else {
          return nil
        }
        
        let measure = Measurement(value: value.doubleValue, unit: unit)
        return measurementFormatter.string(from: measure)
    }
    
}

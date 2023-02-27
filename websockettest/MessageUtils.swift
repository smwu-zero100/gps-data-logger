//
//  MessageUtils.swift
//  websockettest
//
//  Created by 정보인 on 2023/02/27.
//

import Foundation
import CoreLocation

extension Float{
    var bytes:[UInt8]{
        withUnsafeBytes(of: self, Array.init)
    }
}

final class MessageUtils{
    public static func getTimestamp(_ time: Double) -> builtin_interfaces__Time {
        let sec = Int32(time)
        let nanosec = UInt32((time - Double(sec)) * 1000000)
        let time = builtin_interfaces__Time(sec: sec, nanosec: nanosec)
        return time
    }
    
    public static func locationToNavsatFix(time : Double, location:[CLLocationDegrees]) -> sensor_msgs__NavSatFix{
        let header = std_msgs__Header(stamp: self.getTimestamp(time), frame_id: "location")
        let status = sensor_msgs__NavSatStatus(status: 0, service: 1)
        let latitude = location[0]
        let longitude = location[1]
        let altitude = 0.0 //location[2]
        
        return sensor_msgs__NavSatFix(header: header, status: status, latitude: latitude, longitude: longitude, altitude: altitude)
    }
}

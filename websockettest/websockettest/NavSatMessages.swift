//
//  NavSatMessages.swift
//  websockettest
//
//  Created by 정보인 on 2023/02/27.
//

import Foundation

typealias RosMsg = Encodable

/// builtin_interfaces/Time
struct builtin_interfaces__Time: RosMsg {
    var sec: Int32
    var nanosec: UInt32
}

/// std_msgs/Header
struct std_msgs__Header: RosMsg {
    var stamp: builtin_interfaces__Time
    var frame_id: String
}

struct sensor_msgs__NavSatStatus : RosMsg{
    var status:Int8
    var service:UInt16
    
    static let STATUS_NO_FIX : Int8 = -1
    static let STATUS_FIX : Int8 = 0
    static let STATUS_SBAS_FIX : Int8 = 1
    static let STATUS_GBAS_FIX : Int8 = 2
    
    static let SERVICE_GPS : UInt16 = 1
    static let SERVICE_GLONASS : UInt16 = 2
    static let SERVICE_COMPASS : UInt16 = 4
    static let SERVICE_CALILEO : UInt16 = 8
    
}

// sensor_msgs/NavSatFix
struct sensor_msgs__NavSatFix:RosMsg{
    var header: std_msgs__Header
    var status : sensor_msgs__NavSatStatus
    var latitude : Float64
    var longitude : Float64
    var altitude : Float64
    var position_covariance = [Float64](repeating: 0.0, count: 9)
    var position_covariance_type : UInt8 = 0
    
    static let COVARIANCE_TYPE_UNKNOWN = 0
    static let COVARIANCE_TYPE_APPROXIMATED = 1
    static let COVARIANCE_TYPE_DIAGONAL_KNOWN = 2
    static let COVARIANCE_TYPE_KNOWN = 3

}

struct RosbridgeMsg<T> : Encodable where T : Encodable {
    var seq: Int
    var topic: String
    var type: String?
    var msg: T?
}

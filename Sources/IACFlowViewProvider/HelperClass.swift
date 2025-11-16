//
//  HelperClass.swift
//  IACFlowViewProvider
//
//  Created by Madhan on 15/10/25.
//

import UIKit

/// A request object representing input data required for the In App Charging (IAC) flow.
///
/// This model is used to initiate a flow that requires user identification
/// through phone number, vehicle registration, and optionally, location and device token.
public struct IACFlowRequest {
    let sdkMode: IACSDKMode
    let phoneNumber: String
    let userName: String?
    let vehicleRegNumber: String
    let vehicleID: String
    let vehicleType: IACVehicleType
    let carProductLineName: String
    let carModelName: String?
    public var userLocation: (latitude: Double, longitude: Double) = (0.0, 0.0)
    public var oneSignalID: String?
    
    /// Initializes a new instance of `IACFlowRequest`.
    ///
    /// - Parameters:
    ///   - sdkMode: The mode of SDK View `IACSDKMode` (iap | drivepay | fastag)
    ///   - phoneNumber: The user's phone number.
    ///   - userName: Name of the car user.
    ///   - vehicleRegNumber: The vehicle registration number.
    ///   - vehicleID: A unique identifier for the vehicle.
    ///   - vehicleType: The type of vehicle, either `ev` or `ice` from `IACVehicleType`
    ///   - carProductLineName: Car product line name  like `Curvv EV Accomplished + S 45`
    ///   - carModelName: The car brand model name.
    ///   - userLocation: The latitude and longitude of the device, if available.
    ///   - oneSignalID: The One Signal device token for push notifications.
    ///
    public init(
        sdkMode: IACSDKMode,
        phoneNumber: String,
        userName: String? = nil,
        vehicleRegNumber: String,
        vehicleID: String,
        vehicleType: IACVehicleType,
        carProductLineName: String,
        carModelName: String? = nil,
        userLocation: (latitude: Double, longitude: Double)? = nil,
        oneSignalID: String? = nil
    ) {
        self.sdkMode = sdkMode
        self.phoneNumber = phoneNumber
        self.userName = userName
        self.vehicleRegNumber = vehicleRegNumber
        self.vehicleID = vehicleID
        self.vehicleType = vehicleType
        self.carProductLineName = carProductLineName
        self.carModelName = carModelName
        self.userLocation = userLocation ?? (0.0, 0.0)
        self.oneSignalID = oneSignalID
    }
    
}

// SDK inputs validation error.
public enum IACFlowRequestError: Error {
    case invalidVehicleRegNumber
}


/// The mode of SDK View. For in app payment the SDK mode param will be `.iap`, For fastag related operations SDK mode will be `.fastag` and the `.drivepay` mode will be used to Remote manage DrivePay operations from your phone.
public enum IACSDKMode: String, CaseIterable, Codable {
    case iap, drivepay, fastag
}

/// The type of vehicle, either `ev` or `ice`.
public enum IACVehicleType: String, CaseIterable, Codable {
    case ev, ice
}

extension String {
    var isVelidNonEmptyNonNull: Bool {
        // Trim whitespace and new line then check if the string is empty
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        // Check if the trimmed string is not empty and does not contain "Null" (Case-insensitive)
        return !trimmed.isEmpty && trimmed.lowercased() != "null"
    }
    
}

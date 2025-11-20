
// import Foundation
// import UIKit

// import InAppChargingSDKiOS

// public final class IACFlowViewProvider {
    
//     public var requestType = InAppChargingSDKiOS.IACFlowRequest.self
    
//     public static func requestToRegisterDevice(
//         from rootViewController: UIViewController,
//         request:IACFlowRequest,
//         completion: @escaping (Result<Bool, any Error>) -> Void
//     ) {
//         var parsedRequest: InAppChargingSDKiOS.IACFlowRequest = InAppChargingSDKiOS.IACFlowRequest(sdkMode: InAppChargingSDKiOS.IACSDKMode(rawValue: request.sdkMode.rawValue) ?? InAppChargingSDKiOS.IACSDKMode.iap, phoneNumber: request.phoneNumber, userName: request.userName, vehicleRegNumber: request.vehicleRegNumber, vehicleID: request.vehicleID, vehicleType: InAppChargingSDKiOS.IACVehicleType(rawValue: request.vehicleType.rawValue) ?? InAppChargingSDKiOS.IACVehicleType.ev, carProductLineName: request.carProductLineName, carModelName: request.carModelName, userLocation:    (request.userLocation.0, request.userLocation.1), oneSignalID: request.oneSignalID)
//         InAppChargingSDkiOS.requestToRegisterDevice(with: parsedRequest, completion: completion)

//     }
 
//     public static func getHelperFlowViewController(with request: IACFlowRequest, viewController: UIViewController) throws -> UIViewController
//     {
     
//         var parsedRequest: InAppChargingSDKiOS.IACFlowRequest = InAppChargingSDKiOS.IACFlowRequest(sdkMode: InAppChargingSDKiOS.IACSDKMode(rawValue: request.sdkMode.rawValue) ?? InAppChargingSDKiOS.IACSDKMode.iap, phoneNumber: request.phoneNumber, userName: request.userName, vehicleRegNumber: request.vehicleRegNumber, vehicleID: request.vehicleID, vehicleType: InAppChargingSDKiOS.IACVehicleType(rawValue: request.vehicleType.rawValue) ?? InAppChargingSDKiOS.IACVehicleType.ev, carProductLineName: request.carProductLineName, carModelName: request.carModelName,userLocation:    (request.userLocation.0, request.userLocation.1), oneSignalID: request.oneSignalID,)
        
        
//         do {
//                return try InAppChargingSDkiOS.getHelperFlowViewController(
//                    with: parsedRequest,
//                    viewController: viewController
//                )
//            }  catch {
//                throw IACFlowRequestError.invalidVehicleRegNumber
//            }
        
        
//     }
    
//     public static func clearAllData(completion:@escaping (_ isSuccess: Bool)->Void) {
//         InAppChargingSDkiOS.clearIAPData(completion: completion )
//     }
    
// }

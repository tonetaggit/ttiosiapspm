// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "IACFlowViewProvider",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "IACFlowViewProvider",
            targets: ["IACFlowViewProvider"]),
    ],
    dependencies:[

                .package(url: "https://github.com/googlemaps/ios-maps-sdk", from: "8.4.0")
    ],
    targets: [             
        .target(
            name: "IACFlowViewProvider",
            dependencies: [
                "App",
                "image_picker_ios",
                "InAppChargingSDKiOS",
                "webview_flutter_wkwebview",
                "share_plus",
                "path_provider_foundation",
                "device_info_plus",
                "mobile_scanner",
                "vibration"
     
            ],
            
            path: "Sources/IACFlowViewProvider",
            

        ),

            .binaryTarget(
                name: "App",
                path: "./App.xcframework"
            ),
          

         .binaryTarget(
             name: "InAppChargingSDKiOS",
             path:"./InAppChargingSDKiOS.xcframework"
         ),

         .binaryTarget(
             name: "webview_flutter_wkwebview",
             path:"./webview_flutter_wkwebview.xcframework"
                
         ),
         .binaryTarget(
             name: "share_plus",
             path:"./share_plus.xcframework"
                
         ),
         .binaryTarget(
             name: "path_provider_foundation",
             path:"./path_provider_foundation.xcframework"
                
         ),
         .binaryTarget(
             name: "image_picker_ios",
             path:"./image_picker_ios.xcframework"
                
         )
,
         .binaryTarget(
             name: "device_info_plus",
             path:"./device_info_plus.xcframework"
                
         ),
         .binaryTarget(
             name: "mobile_scanner",
             path:"./mobile_scanner.xcframework"
                
         ),
         .binaryTarget(
             name: "vibration",
             path:"./vibration.xcframework"
                
         )
    ]
)


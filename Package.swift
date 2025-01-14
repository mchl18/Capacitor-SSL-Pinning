// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorSslPinning",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorSslPinning",
            targets: ["SSLCertificateCheckerPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SSLCertificateCheckerPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/SSLCertificateCheckerPlugin"),
        .testTarget(
            name: "SSLCertificateCheckerPluginTests",
            dependencies: ["SSLCertificateCheckerPlugin"],
            path: "ios/Tests/SSLCertificateCheckerPluginTests")
    ]
)
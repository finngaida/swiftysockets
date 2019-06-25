// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name:  "swiftysockets",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "swiftysockets",
            targets: ["swiftysockets"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/finngaida/Tide", from: "0.1.1")
//        .package(url: "../Tide", from: "0.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "swiftysockets") //), dependencies: ["Tide"])
//        .systemLibrary(
//            name: "Tide",
//            pkgConfig: "tide",
//            providers: [.brew(["finngaida/formulae/tide"])]
//        )
    ]
)

// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name:  "swiftysockets",
  dependencies: [
    .package(url: "../Tide", .exact("0.1.1"))
  ]
)

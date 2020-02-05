// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Youda",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
  ],
  products: [
    .library(
      name: "youda",
      targets: ["youda"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/industrialbinaries/ASN1Decoder",
      .branch("master")
    ),
  ],
  targets: [
    .target(
      name: "youda",
      dependencies: ["ASN1Decoder"]
    ),
    .testTarget(
      name: "youdaTests",
      dependencies: ["youda", "ASN1Decoder"]
    ),
  ]
)

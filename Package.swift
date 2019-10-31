// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Tabs",
  platforms: [
    .iOS(.v11)
  ],
  products: [
    .library(name: "Tabs", targets: ["Tabs"])
  ],
  targets: [
    .target(
        name: "Tabs",
        path: "./Tabs/Sources")
  ]
)

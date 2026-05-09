// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "deckle",
    products: [
        .library(name: "DeckleCore", targets: ["DeckleCore"]),
        .executable(name: "Deckle", targets: ["DeckleApp"])
    ],
    targets: [
        .target(name: "DeckleCore"),
        .executableTarget(name: "DeckleApp", dependencies: ["DeckleCore"]),
        .testTarget(name: "DeckleCoreTests", dependencies: ["DeckleCore"])
    ]
)

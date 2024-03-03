// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let coreMaps = MapsDependency.coreMaps(version: "11.2.0-1")
let common = MapsDependency.common(version: "24.2.0-1")

let mapboxMapsPath: String? = nil

let package = Package(
    name: "MapboxMaps",
    defaultLocalization: "en",
    // Maps SDK doesn't support macOS but declared the minimum macOS requirement with downstream deps to enable `swift run` cli tools
    platforms: [.iOS(.v12), .macOS(.v10_15), .custom("visionos", versionString: "1.0")],
    products: [
        .library(
            name: "MapboxMaps",
            targets: ["MapboxMaps"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mapbox/turf-swift.git", exact: "2.8.0"),
    ] + coreMaps.packageDependencies + common.packageDependencies,
    targets: [
        .target(
            name: "MapboxMaps",
            dependencies: [
                coreMaps.mapsTargetDependencies,
                common.mapsTargetDependencies,
                .product(name: "Turf", package: "turf-swift")
            ],
            path: mapboxMapsPath,
            exclude: [
                "Info.plist",
            ],
            resources: [
                .copy("MapboxMaps.json"),
                .copy("PrivacyInfo.xcprivacy"),
            ]
        ),
        .testTarget(
            name: "MapboxMapsTests",
            dependencies: [
                "MapboxMaps",
            ],
            resources: [
                .copy("MigrationGuide/Fixtures/polygon.geojson"),
                .copy("Helpers/MapboxAccessToken"),
                .copy("Resources/empty-style-chicago.json"),
                .copy("Snapshot/testDoesNotShowAttribution().png"),
                .copy("Snapshot/testDoesNotShowLogo().png"),
                .copy("Snapshot/testDoesNotShowLogoAndAttribution().png"),
                .copy("Snapshot/testShowsLogoAndAttribution().png"),
                .copy("Snapshot/testSnapshotAttribution-100.png"),
                .copy("Snapshot/testSnapshotAttribution-150.png"),
                .copy("Snapshot/testSnapshotAttribution-200.png"),
                .copy("Snapshot/testSnapshotAttribution-250.png"),
                .copy("Snapshot/testSnapshotAttribution-300.png"),
                .copy("Snapshot/testSnapshotAttribution-50.png"),
                .copy("Snapshot/testSnapshotLogoVisibility.png"),
                .copy("Snapshot/testSnapshotOverlay.png"),
                .process("Resources/MapInitOptionsTests.xib"),
            ]
        )
    ] + coreMaps.packageTargets + common.packageTargets
)

struct MapsDependency {
    init(name: String, version: String, checksum: String? = nil, isSnapshot: Bool?, repositoryName: String, registryProjectName: String, registryFileName: String) {
        self.name = name
        self.version = version
        self.checksum = checksum
        self.isSnapshot = isSnapshot ?? version.contains("SNAPSHOT")

        self.repositoryName = repositoryName
        self.registryProjectName = registryProjectName
        self.registryFileName = registryFileName
    }

    let name: String
    let version: String
    let checksum: String?
    let isSnapshot: Bool

    let repositoryName: String
    let registryProjectName: String
    let registryFileName: String

    static func coreMaps(version: String, checksum: String? = nil, isSnapshot: Bool? = nil) -> MapsDependency {
        return MapsDependency(name: "MapboxCoreMaps", version: version, checksum: checksum, isSnapshot: isSnapshot,
                              repositoryName: "mapbox-core-maps-ios",
                              registryProjectName: "mobile-maps-core",
                              registryFileName: "MapboxCoreMaps")
    }

    static func common(version: String, checksum: String? = nil, isSnapshot: Bool? = nil) -> MapsDependency {
        return MapsDependency(name: "MapboxCommon", version: version, checksum: checksum, isSnapshot: isSnapshot,
                              repositoryName: "mapbox-common-ios",
                              registryProjectName: "mapbox-common",
                              registryFileName: "MapboxCommon")
    }

    var packageDependencies: [Package.Dependency] {
        guard !isSnapshot else { return [] }

        return [
            .package(url: repositoryURL, exact: Version(stringLiteral: version))
        ]
    }

    var packageTargets: [Target] {
        guard isSnapshot else { return [] }

        return [
            .binaryTarget(name: name, url: registryURL, checksum: checksum ?? "")
        ]
    }

    var mapsTargetDependencies: Target.Dependency {
        if isSnapshot {
            return .byName(name: name)
        } else {
            return .product(name: name, package: repositoryName)
        }
    }

    var repositoryURL: String { return "https://github.com/wmanth/\(repositoryName).git" }

    var registryReleaseFolder: String { isSnapshot ? "snapshots" : "releases" }

    var registryURL: String {
        return "https://mapbox.wmanth.net/packages/\(registryFileName)-\(version).zip"
    }
}

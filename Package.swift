import PackageDescription

let package = Package(
    name: "BotBot",
    dependencies: [
        .Package(url: "https://github.com/qutheory/vapor.git", Version(0,4,0))
    ]
)

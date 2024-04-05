![](__docs/github-social-media.png)

# Fardal
> This sample for an inventory app is used to explore the possiblities of a pure vanilla Swift, SwiftUI, SwiftData and CoreML based application.
> Currently it is in active development and works as a playground for myself. Please do not use it.

## Information
Due to the always breaking `SwiftData` information management and the lack of a proper community in context of more than a ToDo app, this repository is currently on hold.

 ## Build status

|Service|Status|
|-------|------|
|-|-|

## Requirements
- Xcode 15+
- iOS 17+
- Swift 5.9
- [Download](https://developer.apple.com/machine-learning/models/) ML model from Apple

## Build tooling
To have a versioned build phase tooling chain, the app uses [`mint`](https://github.com/yonaskolb/Mint) to have a defined version set of tools. 

## Tech stack
`Fardal` is meant to be 100% Swift and dependency-free app. It uses Swift, SwiftUI and SwiftData to be implemented. Simple external dependencies like a helper to work with `SFSymbols` are in use.

Besides this, the app should only be designed using 100% stock controls. Additional styles for buttons or text are only allowed if the do not have any fallback to `UIKit` or other `inspect`-ion helpers to achieve the design.

In later versions, Fardal could contain other Apple fameworks like `MLKit`.

## Build tooling
|Name|Configuration file|
|-|-|
|SwiftLint|`.swiftlint`|
|SwiftFormat|`.swiftformat`|

### How to run
Because of the SwiftUI Preview feature, mint will not run during build time. It would run every Preview refresh which lets Xcode crash.

The `SwiftFormat` command will be currently triggered by a shell command:
```shell
mint run swiftformat .
```

## Terminology
|Name|Description|
|-|-|
|Fardal|Welsh for 'inventory'|
|Collection|A summary of 'items' like "Trading cards" or "Rasberry Pis"
|Item|A specific item you want to track like "Raspberry Pi 3B|
|Image|An optional part of an 'Item' to have a better rememberence for this item. Can be a photo or a custom make symbol|
|Symbol|Apple speak for an 'Icon' with a fore- and background color


## Blockers fixed
### Vesion 0.0.2
Getting `MLKit` to be helpful at image detection / recognition. I use Apple's `MobileNetV2` model but it fails to recognize for example an USB-cabel. In this case it means that it is a doctor's stetoscope. Blocker from 0.0.1 still exists for 1:n relationships.

### Version 0.0.1
I'm struggeling hard to get the `SwiftData` with inter-model relationships working. The unnamed Xcode crashes with no helpful stack-trace are a real bummer to continue with this app.

## How it looks
### Version 0.0.x

**Row contents**
1. Dashboard in empty and filled
2. Collection detail in read and edit mode
3. Item detail in empty and read mode
4. Profile, Image detail, Symbol wizard
5. Search by handwritten code

| | | | |
|-|-|-|-|
|<img src="__docs/001-dashboard-empty-light.png"/>|<img src="__docs/001-dashboard-filled-light.png"/>|
|<img src="__docs/001-collection-detail.png"/>|<img src="__docs/001-collection-detail-edit.png"/>||||
|<img src="__docs/001-item-detail-empty-1.png"/>|<img src="__docs/001-item-detail-empty-2.png" />|<img src="__docs/001-item-detail-1.png"/>|<img src="__docs/001-item-detail-2.png" />|
|<img src="__docs/001-profile.png"/>|<img src="__docs/001-symbol-wizard.png"/>|<img src="__docs/001-image-detail.png"/>|<img src="__docs/002-camera.jpeg"/>|
|<img src="__docs/002-search-by-code.png" />||||


## Used dependencies

|Name|Will be replaced by own code|
|-|-|
|[SFSafeSymbols](https://github.com/SFSafeSymbols/SFSafeSymbols)|no|
|[SwiftUI-Flow](https://github.com/tevelee/SwiftUI-Flow)|yes, it will be replaced with `FlowRowLayout`|

## Branching guideline
### Terminology
|Name|Description|
|-|-|
|`production`|Contains the latest source that are pushed to AppStoreConnect|
|`main`|Always buildable source that are currently in development|
|`t.scholze/38-poc-profile`|Contains the updates of `main` in addition of the feature in progress work|

### Merge permission
1. `production` is only updated via merges from `main`. No pushes or merges other branches allowed
2. `main` gets its update from feature branches. Direct pushes are allowed but not promoted
3. `feature` gets its update from developer's pushes or back merges from `main` but never from `production`

## Keep in mind

### Not production ready
This app is purely build for educational usage! All features have room for improvements or could be done more elegant. This app was and will be never meant to run in production-like environments. Learning is fun!

### Thanks to
- shinnayu from the iOS Development Discord

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
Dependencies or assets maybe licensed differently.

# Agora API Example for iOS with Symbl.ai

*English | [中文](README.zh.md)*

This project presents you a set of API examples to help you understand how to use Agora APIs.

## Problem
After users upgrade their iOS devices to iOS 14.0, and use an app that integrates the Agora RTC SDK for iOS for the first time, users see a prompt for finding local network devices. The following picture shows the pop-up prompt:

![](./pictures/ios_14_privacy.png)

[Solution](https://docs.agora.io/en/faq/local_network_privacy)

## Prerequisites

- Xcode 10.0+
- Physical iOS device (iPhone or iPad)
- iOS simulator is NOT supported

## Quick Start

This section shows you how to prepare, build, and run the sample application.

### Prepare Dependencies

Change directory into **iOS** folder, run following command to install project dependencies,

```
pod install
```

Verify `APIExample.xcworkspace` has been properly generated.

### Obtain an App Id

To build and run the sample application, get an App Id:

1. Create a developer account at [agora.io](https://dashboard.agora.io/signin/). Once you finish the signup process, you will be redirected to the Dashboard.
2. Navigate in the Dashboard tree on the left to **Projects** > **Project List**.
3. Save the **App Id** from the Dashboard for later use.
4. Generate a temp **Access Token** (valid for 24 hours) from dashboard page with given channel name, save for later use.

5. Open `APIExample.xcworkspace` and edit the `KeyCenter.swift` file. In the `KeyCenter` struct, update `<#Your App Id#>` with your App Id, and change `<#Temp Access Token#>` with the temp Access Token generated from dashboard. Note you can leave the token variable `nil` if your project has not turned on security token.

    ``` Swift
    struct KeyCenter {
        static let AppId: String = <#Your App Id#>
        
        // assign token to nil if you have not enabled app certificate
        static var Token: String? = <#Temp Access Token#>
    }
    ```

You are all set. Now connect your iPhone or iPad device and run the project.

## Contact Us

- For potential issues, take a look at our [FAQ](https://docs.agora.io/en/faq) first
- Dive into [Agora SDK Samples](https://github.com/AgoraIO) to see more tutorials
- Take a look at [Agora Use Case](https://github.com/AgoraIO-usecase) for more complicated real use case
- Repositories managed by developer communities can be found at [Agora Community](https://github.com/AgoraIO-Community)
- You can find full API documentation at [Document Center](https://docs.agora.io/en/)
- If you encounter problems during integration, you can ask question in [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io)
- You can file bugs about this sample at [issue](https://github.com/AgoraIO/Basic-Video-Call/issues)

## License

The MIT License (MIT)

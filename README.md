# blank-app

This app is an experiment. 
I have configured the `MinimumOSVersion` property with the value `15.0`, so this app requires iOS 15 or later.
However, if you modify the `MinimumOSVersion` property inside the `Info.plist` file, you can install the app on iOS 14 as well.

It is important to note that if a developer team sets a specific minimum iOS version, it means that the app requires certain features that are not present in previous iOS versions.

After compiling the app, you will find an IPA file in the `build_trollstore` folder, which you **must** install with [TrollStore](https://github.com/opa334/TrollStore). 
The difference with IPAs in the `build` folder is that this IPA can write outside of its sandbox. 
I added the `com.apple.private.security.no-sandbox` entitlement to make this possible. 
However, you **can't** install an IPA with this entitlement using sideloading because a third-party code can only be run on an iDevice if and only if Apple approves it.

Every app that you build with Xcode contains a [provisioning file](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles) which specifies the entitlements that can be used for a specific app.
These files are digitally signed, so they can't be altered.
While you can create your provisioning file, you must enroll in the Apple Developer Program to do so. 
However, this doesn't mean that you can use every possible entitlement.

<span><!-- https://discord.com/channels/779134930265309195/944462595996405810/1087048714524315728 --></span>
In general it's necessary to have a JB or certain types of exploits to use most entitlements.

> **Warning**<br>
> <span><!-- https://sideloadly.io/#faq --></span>
> Another limitation with a Free Apple Developer account is that you can only create up to 10 App IDs every 7 days, after which you'll receive the error message: `Your maximum App ID limit has been reached`. 
> Unfortunately, there is no proper solution to this issue. 
> One workaround is to reuse a previously used App ID but you **cannot install** two apps with the same App ID. 
> After 7 days, the oldest provisioning file will expire, and you can then use its App ID. 
> Alternatively, you can create a new Apple ID.
> Additionally, with a free account, you can only register a maximum of 5 iDevices with your development team ID. 
> Once this limit is reached, `xcodebuild` will show the error message: `Your development team has reached the maximum number of registered iPhone devices.`
> Lastly, for iOS 10, 11, 12, 13, 14, 15, 16, and higher, Apple has limited the number of sideloaded apps that you can install on your device to 3 at a time for free Apple Developer accounts. 
> Paid Apple Developer accounts do not have such limitations.

## How to pack it into IPA?

1. Clone this project:
   ```shell
   git clone --depth=1 -j8 https://github.com/miticollo/blank-app.git
   ```
2. `xcodebuild` is shipped with Xcode so if necessary you can set the following ENV to use a different Xcode release:
   ```shell
   # I use the latest version of Xcode
   export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
   ```
3. Run
   ```shell
   ./build.sh <TEAM_ID> <BUNDLE_ID>
   ```
   To successfully compile it with a free developer account you must override two things.
   - The `<BUNDLE_ID>` currently value is `it.uniupo.dsdf.BlankApp`. You can add a char or completely change this string. It's up to you!
   - You **can't use** my developer team ID you must find yours (see [here](https://github.com/miticollo/test-appium#team-id)).

The IPAs are in `build*` directories.

To clean build folders you can use `build.sh clean`.

## Result

There are two screenshot for iPhone X because the PongoOS KPF applies a patch that permits an app to be unsandboxed.
A similar output is expected also for iPhone XR without TrollStore but using IPA in `build` folder because the other can't be installed (see above).

iPhone X with iOS 16.3.1               |  iPhone X with iOS 16.3.1 + PongoOS KPF
:-------------------------------------:|:-----------------------------------------:
![iPhoneX](./screenshot/iphonex.png)   |  ![iPhoneXJB](./screenshot/iphonexjb.png)
iPhone XR with iOS 15.1b1 (TrollStore) |  iPhone SE 2020 with iOS 14.4.2 
![iPhoneXR](./screenshot/iphonexr.png) |  ![iPhoneSE](./screenshot/iphonese.png)

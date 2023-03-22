# blank-app

This app is an experiment. 
I configured the property `MinimumOSVersion` with the value `15.0`. So this app requires iOS 15+, but if you change `MinimumOSVersion` inside `Info.plist` you can install it on iOS 14.

It's important to notice that this is a simple app. 
If a developer team sets a specific minimum iOS version it means that it requires some specific features that are not present in previous iOS versions.

Furthermore after compiling it you can find in `build_trollstore` an IPA that you **must** install with [TrollStore](https://github.com/opa334/TrollStore). 
The different with IPAs in `build` folder is that this can write outside of its sandox.
This is possible because I added `com.apple.private.security.no-sandbox` entitlement. 
But you **can't** install an IPA with this entitlement using sideloadling because a third-party code can be run on iDevice **if and only if** Apple wants.
In particular every app that you build with Xcode contains a [provisioning file](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles).
This file contains what entitlements you can use for a specific app.
Obviously these file are digitally signed so they can't be altered.
Anyway you can create your provisioning file but you must enroll in the Apple Developer Program.
This doesn't mean that you can use every possible entitlement.

<span><!-- https://discord.com/channels/779134930265309195/944462595996405810/1087048714524315728 --></span>
In general it's necessary to have a JB or certain types of exploits to use most entitlements.

> **Warning**<br>
> <span><!-- https://sideloadly.io/#faq --></span>
> Another limit with Free Apple Developer account is: `Your maximum App ID limit has been reached. You may create up to 10 App IDs every 7 days.`
> This limit doesn't have a proper solution you can reuse a previously App ID, but you  **can't** install two apps with the same App ID.
> This is a workaround.
> After 7 days the oldest provisiong file will expire and you could use its App ID.
> You can also create a new Apple ID.<br/>
> Furthermore with a free account you have a maximum number of iDevice that you can register with your development team ID (currently fixed at 5).
> And if you reach this limit `xcodebuild` complains: `Your development team has reached the maximum number of registered iPhone devices.`.<br/>
> Lastly on iOS 10, 11, 12, 13, 14, 15, 16 and higher, you can only have 3 sideloaded apps installed on your device at the same time. 
> Apple has limited this and will not allow any more for free Apple Developer accounts. 
> A paid Apple Developer Account does not have such limitations.

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
3. <span id="uuid"></span>
   Run
   ```shell
   ./build.sh <TEAM_ID> <BUNDLE_ID>
   ```
   To successfully compile it with a free developer account you must override two things.
   - The `<BUNDLE_ID>` currently value is `it.uniupo.dsdf.BlankApp`. You can add a char or completely change this string. It's up to you!
   - You **can't use** my developer team ID you must find yours.
     To do this you must download a provisioning file from Xcode (Preferences... > Accounts > Download Manual Profiles).
     <span><!-- https://guides.codepath.com/ios/Provisioning-Profiles --></span>
     Now you will find the downloaded profile in `~/Library/MobileDevice/Provisioning/ Profiles/`.
     To inspect `*.mobileprovision` you can use:
     <span><!-- https://stackoverflow.com/a/33813384 --></span>
     ```shell
     security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/<UUID>.mobileprovision | plutil -extract 'TeamIdentifier'.0 raw -o - -- -
     ```

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

![Veryfi Logo](https://cdn.veryfi.com/logos/veryfi-logo-wide-github.png)

![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)
![iOS 15.2](https://img.shields.io/badge/iOS-15.2-blue.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
# Veryfi Lens
Veryfi Lens is code (a framework) with UI for your mobile app to give it document capture superpowers in minutes.

Let Veryfi handle the complexities of frame processing, asset preprocessing, edge routing, and machine vision challenges in document capture. We have been at this for a long time and understand the intricate nature of mobile capture. That’s why we built Lens. Veryfi Lens is built by developers for developers; making the whole process of integrating Lens into your app fast and easy with as few lines as possible.

Veryfi Lens is a Framework: a self-contained, reusable chunks of code and resources you can import into you app.

Lens is built in native code and optimized for fast performance, clean user experience and low memory usage.

You can read further about Lens in Veryfi's dedicated page: https://www.veryfi.com/lens/

## Table of content
1. [Veryfi Lens iOS Example](#example)
2. [Other Lens iOS Examples](#examples)
3. [Configuration](#configuration)
4. [Other platforms](#other_platforms)
5. [Get in contact with our team](#contact)

## Veryfi Lens iOS Example <a name="example"></a>

![gif-receipts](https://user-images.githubusercontent.com/30237430/162517329-ac52098b-4220-488b-9fbb-debcf25c70e0.gif)

## Other Lens iOS Examples <a name="examples"></a>
This is an example of how to use Veryfi Lens Receipts in your app, you can find the developer documentation [here](iOSLensReceipts.pdf).
You can find five example projects, which are the five versions of Lens that we currently offer:
- [Lens for Long Receipts](https://github.com/veryfi/veryfi-lens-long-receipts-ios-demo)
- [Lens for Receipts](https://github.com/veryfi/veryfi-lens-receipts-ios-demo)
- [Lens for Credit Cards](https://github.com/veryfi/veryfi-lens-credit-cards-ios-demo)
- [Lens for Business Cards](https://github.com/veryfi/veryfi-lens-business-cards-ios-demo)
- [Lens for Checks](https://github.com/veryfi/veryfi-lens-checks-ios-demo)

### Configuration <a name="configuration"></a>
- Make sure your iOS credentials are set to access Veryfi's private Cocoapods repository [here](https://hub.veryfi.com/api/settings/keys). 

### Optional: Git credentials tool
If you want to avoid typing the credentials you set in the previous step everytime you run pod install run `git credential approve` and type in a single entry the following information:

```
protocol=https
host=repo.veryfi.com
path=shared/lens/veryfi-lens-podspec.git
username=YOUR_USERNAME
password=YOUR_PASSWORD

```

- Clone this repository
- Run `pod install --repo-update` to install VeryfiLens and its dependencies
- Open the workspace within the project in Xcode
- Replace credentials in `ViewController` with yours
```
let CLIENT_ID = "XXX" // replace XXX with your assigned Client Id
let AUTH_USERNAME = "XXX" // replace XXX with your assigned Username
let AUTH_APIKEY = "XXX" // replace XXX with your assigned API Key
let URL = "XXX" // replace XXX with your assigned Endpoint URL
```
- Run the project

### Other platforms <a name="other_platforms"></a>
You can find these examples for Android [here](https://github.com/veryfi?q=android&type=all). We also support the following wrappers for hybrid frameworks:
- [Cordova](https://hub.veryfi.com/lens/docs/cordova/)
- [React Native](https://hub.veryfi.com/lens/docs/react-native/)
- [Flutter](https://hub.veryfi.com/lens/docs/flutter/)
- [Xamarin](https://hub.veryfi.com/lens/docs/xamarin/)

If you don't have access to our Hub, please contact our sales team, you can find the contact bellow.

### Get in contact with our sales team <a name="contact"></a>
Contact sales@veryfi.com to learn more about Veryfi's awesome products.


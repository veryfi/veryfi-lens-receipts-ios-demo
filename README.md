<img src="https://user-images.githubusercontent.com/30441118/212185646-f96d2e4c-daf4-4286-8f1b-c92058224b87.png#gh-dark-mode-only" width="200">
<img src="https://user-images.githubusercontent.com/30441118/212185644-ab61c399-0f0c-4d22-a361-0191632d63d2.png#gh-light-mode-only" width="200">

![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)
![iOS 15.2](https://img.shields.io/badge/iOS-15.2-blue.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
# Veryfi Lens

<a href="https://apps.apple.com/co/app/veryfi-lens/id1498300628?l=en"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Download_on_the_App_Store_Badge.svg/2560px-Download_on_the_App_Store_Badge.svg.png" width="200"></a>&nbsp;&nbsp;
<a href="https://play.google.com/store/apps/details?id=com.veryfi.lensdemo"><img src="https://en.logodownload.org/wp-content/uploads/2019/06/get-it-on-google-play-badge-1.png" width="200"></a>

Veryfi Lens is code (a framework) with UI for your mobile app to give it document capture superpowers in minutes.

Let Veryfi handle the complexities of frame processing, asset preprocessing, edge routing, and machine vision challenges in document capture. We have been at this for a long time and understand the intricate nature of mobile capture. That’s why we built Lens. Veryfi Lens is built by developers for developers; making the whole process of integrating Lens into your app fast and easy with as few lines as possible.

Veryfi Lens is a Framework: a self-contained, reusable chunks of code and resources you can import into you app.

Lens is built in native code and optimized for fast performance, clean user experience and low memory usage.

You can read further about Lens in Veryfi's dedicated page: https://www.veryfi.com/lens/

You can watch our video:
[![Veryfi Lens](https://img.youtube.com/vi/P84RDJimEtA/maxresdefault.jpg)](http://www.youtube.com/watch?v=P84RDJimEtA "Veryfi Lens Integration in Swift")

## Table of content
1. [Veryfi Lens iOS Examples](#examples)
2. [How to add Veryfi Lens to your project](#cocoapods)
3. [How to run this project](#configuration)
4. [Other platforms](#other_platforms)
5. [Get in contact with our team](#contact)

## Veryfi Lens Receipts & Invoices iOS Example <a name="example"></a>
This is an example of how to use Veryfi Lens Receipts & Invoices in your app, you can find the developer documentation [here](https://app.veryfi.com/lens/docs/ios/).

![receipt-demo](https://user-images.githubusercontent.com/8684090/236651344-306b1f55-a690-4151-87bd-c08d4d9297de.gif)

## How to add Veryfi Lens Receipts to your project <a name="cocoapods"></a>

Install from our private [Cocoapods](https://hub.veryfi.com/api/settings/keys).

Add in your project Podfile file the Veryfi Lens Receipts iOS SDK dependency:
```ruby
pod 'VeryfiLens-Receipts', '2.0.11.1'
```

## How to run this project <a name="configuration"></a>
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

## Other Lens iOS Examples <a name="examples"></a>
You can find some example projects, which are the different versions of Lens that we currently offer:
- [Lens for Long Receipts](https://github.com/veryfi/veryfi-lens-long-receipts-ios-demo)
- [Lens for Receipts](https://github.com/veryfi/veryfi-lens-receipts-ios-demo)
- [Lens for Credit Cards](https://github.com/veryfi/veryfi-lens-credit-cards-ios-demo)
- [Lens for Business Cards](https://github.com/veryfi/veryfi-lens-business-cards-ios-demo)
- [Lens for Checks](https://github.com/veryfi/veryfi-lens-checks-ios-demo)
- [Lens for W-2](https://github.com/veryfi/veryfi-lens-w2-ios-demo)
- [Lens for W-9](https://github.com/veryfi/veryfi-lens-w9-ios-demo)

## Other platforms <a name="other_platforms"></a>
You can find these examples for Lens Android 
- [Long Receipts](https://github.com/veryfi/veryfi-lens-long-receipts-android-demo)
- [Receipts](https://github.com/veryfi/veryfi-lens-receipts-android-demo)
- [Credit Cards](https://github.com/veryfi/veryfi-lens-credit-cards-android-demo)
- [Business Cards](https://github.com/veryfi/veryfi-lens-business-cards-android-demo)
- [Checks](https://github.com/veryfi/veryfi-lens-checks-android-demo)
- [W-2](https://github.com/veryfi/veryfi-lens-w2-android-demo)
- [W-9](https://github.com/veryfi/veryfi-lens-w9-android-demo)

We also support the following wrappers for hybrid frameworks:
- [Cordova](https://hub.veryfi.com/lens/docs/cordova/)
- [React Native](https://hub.veryfi.com/lens/docs/react-native/)
- [Flutter](https://hub.veryfi.com/lens/docs/flutter/)
- [Xamarin](https://hub.veryfi.com/lens/docs/xamarin/)

If you don't have access to our Hub, please contact our sales team, you can find the contact bellow.

## Get in contact with our sales team <a name="contact"></a>
Contact sales@veryfi.com to learn more about Veryfi's awesome products.

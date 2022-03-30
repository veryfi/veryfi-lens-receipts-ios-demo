# Veryfi Lens
Veryfi Lens is code (a framework) with UI for your mobile app to give it document capture superpowers in minutes.

Let Veryfi handle the complexities of frame processing, asset preprocessing, edge routing, and machine vision challenges in document capture. We have been at this for a long time and understand the intricate nature of mobile capture. That’s why we built Lens. Veryfi Lens is built by developers for developers; making the whole process of integrating Lens into your app fast and easy with as few lines as possible.

Veryfi Lens is a Framework: a self-contained, reusable chunks of code and resources you can import into you app.

Lens is built in native code and optimized for fast performance, clean user experience and low memory usage.

You can read further about Lens in Veryfi's dedicated page: https://www.veryfi.com/lens/

## Table of content
1. [Veryfi Lens iOS Examples](#examples)
2. [Configuration](#configuration)
3. [Other platforms](#other_platforms)
4. [Get in contact with our team](#contact)

## Other Lens iOS Examples <a name="examples"></a>
This is an example of how to use Veryfi Lens Receipts in your app, you can find the developer documentation [here](iOSLensLongReceipts.pdf).
You can find five example projects, which are the five versions of Lens that we currently offer:
- [Lens for Long Receipts](https://github.com/veryfi/veryfi-lens-long-receipts-ios-demo)
- [Lens for Receipts](https://github.com/veryfi/veryfi-lens-receipts-ios-demo)
- [Lens for Credit Cards](https://github.com/veryfi/veryfi-lens-credit-cards-ios-demo)
- [Lens for Business Cards](https://github.com/veryfi/veryfi-lens-business-cards-ios-demo)
- [Lens for Checks](https://github.com/veryfi/veryfi-lens-checks-ios-demo)

### Configuration <a name="configuration"></a>
- Make sure your SSH key has been granted access to Veryfi's private Cocoapods repository [here](https://hub.veryfi.com/api/settings/keys/#package-managers-container). Also make sure your SSH key has been added to ssh-agent by running this command in the Terminal:
```
# Replace /path/to/private_key with the actual path to your SSH private key
ssh-add -K /path/to/private_key
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


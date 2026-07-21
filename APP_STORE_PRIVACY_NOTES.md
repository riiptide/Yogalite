# Yogalite App Store Privacy Notes

Use these answers for App Store Connect as long as Yogalite has no backend, no third-party analytics SDK, no ads, and no off-device upload of local practice data.

## Privacy Nutrition Label

- Data collected: **No**
- Tracking: **No**
- Data linked to the user: **No**

Yogalite stores preferences, saved practices, completion history, optional profile photo data, and product interaction events locally on the user's device. This data is not transmitted to the developer or third-party services.

## Privacy Manifest

The app privacy manifest should declare:

- `NSPrivacyTracking`: `false`
- `NSPrivacyTrackingDomains`: empty
- `NSPrivacyCollectedDataTypes`: empty
- `NSPrivacyAccessedAPITypes`: UserDefaults with reason `CA92.1`

## Policy Wording

The hosted privacy policy should state:

- No account is required.
- No ads are shown.
- No third-party analytics SDKs are used.
- No tracking occurs across apps or websites.
- Local analytics/product interaction events stay on the device and are not uploaded.
- Deleting the app removes locally stored app data from the device.

If Yogalite later sends analytics, crash reports, account data, support messages, or profile data to a server or third-party provider, update App Store Connect, `PrivacyInfo.xcprivacy`, and the privacy policy before submitting the next build.

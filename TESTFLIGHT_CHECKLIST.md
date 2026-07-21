# Yogalite TestFlight Checklist

## Build
- Scheme: `Yogapp`
- Display name: `Yogalite`
- Bundle ID: `com.riiptide.Yogapp`
- Version: `1.0`
- Build: `1`
- Team ID: `3VD8Z9BKRP`

## App Store Connect
- Beta app name: `Yogalite`
- Beta description: `A light, approachable yoga companion with guided flows, timers, audio cues, saved practices, and personalized recommendations.`
- Feedback email: `a71gtr@gmail.com`
- Support URL: `https://papaya-buttercream-fe4631.netlify.app/`
- Privacy Policy URL: `https://splendorous-cobbler-3fd633.netlify.app/`
- Marketing URL: optional for TestFlight, useful before public release.

## Privacy
- Local profile name and onboarding preferences are stored on-device.
- Profile photos are selected with the system photo picker and stored on-device.
- Product interaction events are stored locally on-device and are not uploaded.
- No tracking domains or third-party analytics SDKs are used.
- Suggested App Privacy answer: No, this app does not collect data.

## Review Notes
- Yogalite is a general wellness yoga app and does not provide medical advice.
- Users should stop if they feel pain or dizziness and consult a qualified professional before starting a new exercise routine when appropriate.
- Audio narration and countdown cues are generated locally using system speech/audio.

## Preflight
- Run tests: `xcodebuild test -project Yogapp.xcodeproj -scheme Yogapp -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2'`
- Create archive: `xcodebuild archive -project Yogapp.xcodeproj -scheme Yogapp -destination 'generic/platform=iOS' -archivePath build/Yogalite.xcarchive`
- Upload from Xcode Organizer after archive succeeds.

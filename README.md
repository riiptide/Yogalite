# Yogalite

Yogalite is a lightweight, personalized yoga companion for iOS. It helps people practice wherever they are without needing full recorded video flows: each practice is built from illustrated poses, timers, audio cues, and simple guidance.

The goal is calm portability. Yogalite should feel useful in a bedroom, hotel room, dorm, office, or quiet corner when someone has five minutes in the morning, ten minutes before bed, or a small pocket of time between everything else.

## Inspiration

If I could build anything today, I would build Yogalite: a gentle yoga app that makes daily practice feel approachable instead of overwhelming. Many fitness apps depend on long videos, subscriptions, accounts, and heavy dashboards. Yogalite takes a lighter path by combining pose illustrations, timer-based flows, audio narration, personalization, and multi-day programs.

## Features

- Guided timer-based yoga practices
- Illustrated poses and transitions
- Audio cues for pose names, breath, hold duration, and left/right side changes
- Searchable library of yoga flows
- Tags, difficulty filters, and duration filters
- Daily Flow that changes once per local calendar day
- Personalized recommended flows based on onboarding preferences
- Multi-day Programs tab
- Saved practices and favorites
- Profile personalization with editable name, goals, and profile photo
- First-launch onboarding
- Post-practice reflection
- Local anonymous product analytics
- Light teal visual design
- Local-first privacy approach with no required account

## Programs

Yogalite includes structured multi-day practice paths:

- 7-Day Intro to Yoga
- 7-Day Power Yoga
- 10-Day Morning Sunrise Pack
- 10-Day Evening Wind-Down Pack
- 15-Day Yoga Mind
- 30-Day Yoga Glow
- 7-Day Yin Yoga

Programs group existing flows into a clear path so users have a reason to come back tomorrow.

## How It Works

Yogalite does not rely on full recorded video classes. Instead, each flow is modeled as a sequence of timed steps:

- Holds
- Transitions
- Breath cues
- Side cues
- Repeated rounds
- Completion states

This keeps the app lightweight while still creating a guided practice experience.

## Tech Stack

- Swift
- SwiftUI
- XCTest
- Local persistence with on-device storage
- Native iOS photo picker and local profile photo handling
- System speech/audio cues

## How Codex and GPT-5.6 Were Used

OpenAI Codex and GPT-5.6 were used as a coding and product-design collaborator throughout the project. They helped turn Yogalite from an initial concept into a polished iOS app by supporting both engineering work and product decisions.

Codex helped with:

- Inspecting the existing SwiftUI codebase before making changes
- Following the app's architecture and coding style
- Building new screens and components incrementally
- Wiring flows, tags, programs, profile features, onboarding, and practice completion
- Debugging build issues and SwiftUI layout problems
- Running tests with `xcodebuild`
- Making focused commits and pushing changes to GitHub
- Preparing TestFlight and App Store readiness notes

GPT-5.6 helped with:

- Product direction and feature prioritization
- UX polish for mobile yoga practice screens
- Copywriting for onboarding, privacy, App Store notes, and Devpost materials
- Thinking through audio cue behavior so narration felt helpful but not repetitive
- Keeping the app lightweight and personalized without requiring video content
- Explaining deployment, TestFlight, and App Store Connect steps

The collaboration was especially useful because Yogalite needed both product taste and implementation detail. Small choices like tag wrapping, card spacing, audio timing, build metadata, privacy messaging, and review notes all mattered.

## Privacy

Yogalite is designed to be privacy-conscious and local-first.

- No account is required.
- Profile name and onboarding preferences are stored on-device.
- Selected goals and saved practices are stored locally.
- Profile photos are selected through the system photo picker and stored on-device.
- Anonymous product analytics are stored locally and are not linked to identity.
- No third-party analytics SDK is required.

## Running the Project

1. Open `Yogapp.xcodeproj` in Xcode.
2. Select the `Yogapp` scheme.
3. Choose an iOS Simulator or a connected iPhone.
4. Build and run.

To run tests:

```sh
xcodebuild test -project Yogapp.xcodeproj -scheme Yogapp -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2'
```

## TestFlight / App Store Notes

The app display name is `Yogalite`.

Suggested review note:

> Yogalite is a general wellness yoga app with guided timer-based flows, illustrated poses, audio cues, saved practices, personalized recommendations, and multi-day programs. The app requires no account and stores user preferences locally.

## What I Learned

Yogalite reinforced that a strong product does not always need more complexity. By avoiding heavy video flows and account-based infrastructure, the app became faster, more flexible, and easier to personalize.

I also learned that polish comes from many small decisions: text wrapping, spacing, audio cue timing, screen wake behavior, approachable copy, and predictable navigation. Together, those details make the app feel trustworthy.

## What's Next

Future improvements could include:

- Optional background music
- Program progress tracking
- Deeper streak and habit insights
- Apple Health integration
- More accessibility refinements
- More adaptive recommendations
- iPad layout support

The long-term vision is for Yogalite to become a gentle daily companion: lightweight, personal, privacy-conscious, and available wherever someone wants to practice.

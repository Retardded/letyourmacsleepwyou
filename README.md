# LetYourMacSleep 💤

> I always fell asleep with a FaceTime call running, and woke up to a dead laptop with a flat battery. So I built this.

A tiny menu bar app for macOS. FaceTime (and Zoom, `caffeinate`, video players, anything else) holds a "prevent sleep" assertion, so your Mac never sleeps, even if you fell asleep hours ago. This app notices that **you're gone** and puts the Mac to sleep anyway.

## How it works

Every 10 seconds it checks:

1. **Input idle time**: no mouse, keyboard or trackpad activity for N minutes (you pick N in the menu).
2. **Microphone** (optional): nothing louder than faint background noise. If you're still talking, it won't sleep.
3. **Blockers**: it only acts if something is actually preventing sleep (`pmset -g assertions`).

If all three say you're away, it quits the apps holding the assertions (FaceTime, etc.) and runs `pmset sleepnow`.

Everything runs locally. Audio is never recorded or stored, only the volume level is measured.

## Download

Grab `LetYourMacSleep.zip` from [Releases](https://github.com/Retardded/letyourmacsleepwyou/releases), unzip, drag to Applications. The app is not notarized, so on first launch right-click → Open (or run `xattr -dr com.apple.quarantine LetYourMacSleep.app`).

## Build from source

Requires macOS 12+ and Xcode Command Line Tools (`xcode-select --install`).

```sh
git clone https://github.com/Retardded/letyourmacsleepwyou.git
cd letyourmacsleepwyou
./build.sh
open LetYourMacSleep.app
```

Allow microphone access when asked (or turn off "Listen to microphone" in the menu and skip it).

To start at login: System Settings → General → Login Items → add `LetYourMacSleep.app`.

## Usage

Click the 💤 icon in the menu bar:

- **Sleep after idle**: 1 / 5 / 10 / 15 / 30 / 60 minutes.
- **Listen to microphone**: treat voice/loud sound as activity.
- **Quit**.

## Caveats

- It closes **every** app that blocks sleep, not just FaceTime. There's no whitelist yet.
- Mic sensitivity is the `loud` constant in `main.swift` (default ≈ −40 dB). Raise it if background noise keeps the Mac awake.
- If the Mac wakes on its own (e.g. network) and you're still idle, it will go back to sleep.

## Test it

Set "1 min", run `caffeinate -i` in a terminal, and walk away. After a minute `caffeinate` should be killed and the Mac should sleep.

## License

MIT

![logo](resource/png/logo.png)

# Kawa [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/utatti/kawa/master/LICENSE)

A macOS input source switcher with user-defined shortcuts.

## Demo

[![demo](https://cloud.githubusercontent.com/assets/1013641/9109734/d73505e4-3c72-11e5-9c71-49cdf4a484da.gif)](http://vimeo.com/135542587)

## Install

Requires a Mac with Apple Silicon and macOS 12.0 or later.

### Download

1. Download `Kawa-<version>.dmg` from
   [Releases](https://github.com/real-michael-zhou/kawa/releases).
2. Open the dmg and drag `Kawa.app` to `Applications`.
3. Kawa is not signed with an Apple Developer ID, so on the first launch
   macOS says *"Apple could not verify “Kawa” is free of malware…"*. Do not
   click **Move to Trash**. Click **Done**, then run this in Terminal:

   ```bash
   $ xattr -dr com.apple.quarantine /Applications/Kawa.app
   ```

   and open Kawa again. Alternatively, go to **System Settings › Privacy &
   Security** and click **Open Anyway** next to the message about Kawa.

### Build from source

Requires Xcode.

```bash
$ git clone git@github.com:real-michael-zhou/kawa.git
$ cd kawa
$ ./scripts/package.sh
```

This builds `build/Kawa-<version>.dmg`. Open it and drag `Kawa.app` to
`Applications`. An app built on your own Mac is not quarantined, so it opens
without the Gatekeeper step above.

To launch Kawa automatically, enable **Launch Kawa at login** in its
preferences.

## Caveats

### CJKV input sources

There is a known bug in the macOS's Carbon library that switching keyboard
layouts using `TISSelectInputSource` doesn't work well with complex input
sources like [CJKV](https://en.wikipedia.org/wiki/CJK_characters).

## Development

Carthage is not required: the dependency (MASShortcut, pinned in
`Cartfile.resolved`) is built directly with `xcodebuild`.

```bash
$ ./scripts/build-deps.sh
```

Then open `kawa.xcodeproj` with Xcode.

### Releasing

Bump `CFBundleShortVersionString` in `kawa/Info.plist`, commit, then push a
matching tag. GitHub Actions builds the dmg and publishes the release.

```bash
$ git tag v1.2.0
$ git push origin v1.2.0
```

## License

Kawa is released under the [MIT License](LICENSE).

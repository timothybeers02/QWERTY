# Setup

This guide walks you through installing the latest Xcode, getting iPad simulators ready, and running the project in Simulator and on a physical iPad.

## 1) System requirements

- A Mac that supports the current Xcode release  
- Latest macOS updates installed  
- ~30–50 GB free disk space for Xcode, simulators, and build artifacts

## 2) Install Xcode

### Option A: Mac App Store (recommended)
1. Open the **App Store** and search for **Xcode**.
2. Click **Get** and wait for the installation to finish.
3. Launch Xcode once so it can install additional components.

### Option B: Apple Developer downloads (for betas or specific versions)
1. Download the `.xip` for the version you need.
2. Expand it and move **Xcode.app** to `/Applications`.
3. If you keep multiple Xcodes, point command-line tools at the one you use:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app
   ```

### Command Line Tools
If prompted, let Xcode install them. You can also run:
```bash
xcode-select --install
```

## 3) Get iPad simulators (iOS runtime)

iPad simulators are part of the iOS runtime.

1. Open Xcode → **Settings…** → **Platforms**.
2. Under **iOS**, click **+** or **Download** to add the iOS runtime you want.
3. Add specific iPad models: **Window** → **Devices and Simulators** → **Simulators** tab → **+** → choose an iPad model and the installed iOS version → **Create**.

## 4) Clone and open the project

```bash
git clone <your-repo-url>
cd QWERTYmoji
xed QWERTYmoji.xcodeproj
```

This project has no external package dependencies.

## 5) Code signing (first run)

1. In Xcode, select the **QWERTYmoji** app target.  
2. Open **Signing & Capabilities**.  
3. Pick your **Team** (Personal Team is fine for development).  
4. Make sure **Automatically manage signing** is checked.

Repeat for any additional targets if present.

## 6) Run in Simulator

1. In the toolbar, pick a scheme such as **QWERTYmoji**.
2. Choose an iPad simulator device, for example **iPad Pro (11-inch)**.
3. Press **Run** (⌘R).

All functionality is built into the app's UI. There is no separate keyboard extension to enable.

## 7) Run on a physical iPad

1. Enable **Developer Mode** on the iPad (iPadOS 16 or later):  
   Settings → Privacy & Security → **Developer Mode** → turn on and restart if asked.
2. Connect the iPad via USB or use wireless debugging. Tap **Trust** on the device if prompted.
3. In Xcode, select your iPad from the run destination menu.
4. Ensure signing is set up for each target (see step 5).
5. Press **Run** (⌘R).

## 8) Running tests

- In Xcode: **Product** → **Test** (⌘U).  
- From the command line (replace device name if needed):
  ```bash
  xcodebuild \
    -scheme QWERTYmoji \
    -destination 'platform=iOS Simulator,name=iPad Pro (11-inch)' \
    test
  ```

## 9) Troubleshooting

- **Signing errors**  
  Check **Team** and **Bundle Identifier** per target. Clean build folder (Shift-⌘-K) and rebuild.

- **"Failed to prepare device for development"**  
  Reconnect the iPad, ensure Developer Mode is on, unlock the device, and keep it on the home screen during the first run.

- **Simulator not showing the right iPad models**  
  Install the matching iOS runtime in **Settings… → Platforms**, then add the device in **Devices and Simulators**.

- **Weird build issues after Xcode updates**  
  Delete DerivedData:
  ```bash
  rm -rf ~/Library/Developer/Xcode/DerivedData
  ```

## 10) What to include in bug reports

- Xcode version (for example, 15.4) and macOS version  
- Target device and iPadOS version  
- Steps to reproduce and which target or scheme you used  
- Any relevant logs from **Report Navigator** or `xcodebuild`


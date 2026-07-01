# LeetTracker Deployment Guide

This document outlines the end-to-end deployment strategy for LeetTracker. It starts with a completely free distribution model (no Apple Developer account required) and outlines the future transition to the official Apple App Stores.

---

## Phase 1: Free Distribution (Unsigned DMG)
Since we are skipping the paid Apple Developer Program for now, the app will be "unsigned." macOS's security system (Gatekeeper) will try to block it, so we have to use specific techniques to distribute it.

### 1. Building and Packaging
1. **Build the Release App:** In Xcode, select the `Release` configuration and build the app. This generates the `LeetTracker.app` file.
2. **Create the DMG:** We will use a command-line tool like `create-dmg` (available via Homebrew) to package `LeetTracker.app` into a drag-and-drop installer:
   ```bash
   create-dmg \
     --volname "LeetTracker Installer" \
     --window-pos 200 120 \
     --window-size 600 400 \
     --icon-size 100 \
     --icon "LeetTracker.app" 175 190 \
     --hide-extension "LeetTracker.app" \
     --app-drop-link 425 190 \
     "LeetTracker.dmg" \
     "path/to/build/LeetTracker.app"
   ```

### 2. Hosting the File
Upload the generated `LeetTracker.dmg` to **GitHub Releases** on your repository. This provides a free, fast, permanent download URL that we can use for the website and Homebrew.

### 3. The Gatekeeper Warning
Because the app is unsigned, users who double-click it will see a warning: *"LeetTracker cannot be opened because the developer cannot be verified."*
**The Fix:** Users must **Right-Click -> Open** the app from their Applications folder the first time. You must put this instruction on your website.

---

## Phase 2: Homebrew Cask (Free)
Homebrew is the best way for developers to install the app. We can also use it to bypass the Gatekeeper warning completely using the `no_quarantine` flag.

1. **Create a Custom Tap:** Create a new public GitHub repository named `homebrew-tap` (URL: `github.com/syedhy/homebrew-tap`).
2. **Create the Cask Script:** Inside that repo, create a file named `Casks/leettracker.rb`:
   ```ruby
   cask "leettracker" do
     version "1.0.0"
     sha256 "THE_SHA_256_HASH_OF_YOUR_DMG_FILE"

     url "https://github.com/syedhy/LeetTracker/releases/download/v#{version}/LeetTracker.dmg"
     name "LeetTracker"
     desc "Your personal LeetCode tracker and planner"
     homepage "https://your-website-url.com"

     app "LeetTracker.app"

     binary "#{appdir}/LeetTracker.app/Contents/Resources/scripts/install-background-refresh-agent.sh", target: "leettracker-install-background-refresh"
     binary "#{appdir}/LeetTracker.app/Contents/Resources/scripts/uninstall-background-refresh-agent.sh", target: "leettracker-uninstall-background-refresh"

     # THIS IS THE MAGIC LINE! It removes the Apple quarantine flag,
     # so users won't get the "Developer cannot be verified" warning.
     auto_updates true
     conflicts_with cask: "leettracker"
     
     postflight do
       system_command "xattr",
                      args: ["-cr", "#{appdir}/LeetTracker.app"],
                      sudo: true
     end
   end
   ```
3. **Install Command:** Users can now install your app seamlessly with:
   ```bash
   brew install syedhy/tap/leettracker
   ```

---

## Phase 3: The Website
To give the app a premium feel, we will build a dedicated landing page.

### Tech Stack: Next.js + Tailwind CSS
This is the modern standard for fast, beautiful, and highly responsive landing pages. 
- **Next.js (React):** Provides lightning-fast page loads (Server-Side Rendering) and is easy to extend.
- **Tailwind CSS:** Allows for rapid UI styling directly in the markup to match the "Doodle/Charades" aesthetic perfectly.
- **Framer Motion (Optional):** For buttery smooth micro-animations.

### Hosting: Vercel (Free)
Vercel created Next.js. You can link your GitHub repository to Vercel, and it will deploy your website for free instantly every time you push code.

### Website Content
- **Hero Section:** A massive, high-quality screenshot/mockup of the macOS app.
- **Primary CTA (Call to Action):** A large "Download for macOS (Free)" button pointing directly to your GitHub Releases DMG link. Include a small subtext: *(See instructions to bypass macOS security)*.
- **Homebrew Section:** A sleek, dark-mode terminal window UI showing the exact `brew install` command, complete with a "Copy to clipboard" icon.

---

## Phase 4: Future App Store Deployment (Paid Apple Developer Program)
When you are ready to pay the $99/year fee, you can move the app to the official App Stores. This removes the need for Gatekeeper workarounds entirely.

### macOS App Store
To get on the Mac App Store, the app must run inside the **App Sandbox**.
1. **Entitlements:** We will add the `com.apple.security.app-sandbox` entitlement to Xcode. We will also need to ensure we request network access entitlements so the LeetCode API still works.
2. **Provisioning:** Create a "Mac App Distribution" provisioning profile in your Apple Developer account.
3. **Upload:** Archive the app in Xcode and open the **Organizer**. Click "Distribute App" -> "App Store Connect".
4. **App Store Connect:** Fill out the description, upload screenshots, set the price to Free, and submit for Apple Review.

### iOS App Store
Since LeetTracker is built with SwiftUI, the codebase is already shared!
1. **Icons and Assets:** Ensure all iOS-specific app icons and launch screens are generated.
2. **Provisioning:** Create an "iOS App Distribution" profile.
3. **Upload:** Change your Xcode build target to "Any iOS Device", click Product -> Archive, and upload via the Xcode Organizer.
4. **TestFlight:** Before releasing, you can invite friends or beta testers using TestFlight directly through App Store Connect.
5. **Release:** Submit for review. Once Apple approves it (usually 24-48 hours), it will be live for anyone with an iPhone/iPad to download globally.

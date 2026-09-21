# Octoscreen

An animated macOS screen saver built from Octicons.

<img width="1276" alt="octoscreen" src="https://cloud.githubusercontent.com/assets/1680/8358041/b1b14da2-1b23-11e5-8cee-7bd165b63fc7.png">

## Requirements

macOS 14 Sonoma or later. Releases are available for both Apple silicon and Intel Macs.

## Install

1. Download the matching archive from the [latest release](https://github.com/niu541412/octoscreen/releases/latest):
   - `Octoscreen-arm64.saver.zip` for Apple silicon (M-series) Macs.
   - `Octoscreen-x86_64.saver.zip` for Intel Macs.
2. Unzip the archive and double-click `Octoscreen.saver`.
3. Select **Octoscreen** in **System Settings → Screen Saver**.

Releases are ad-hoc signed. macOS may require confirmation in **System Settings → Privacy & Security** before it will load the saver.

## Building a release

Push a version tag such as `v1.1.0`. GitHub Actions builds, validates, and publishes separate archives for Apple silicon and Intel Macs.

To distribute without Gatekeeper confirmation, add Developer ID signing and Apple notarization credentials to the release workflow.

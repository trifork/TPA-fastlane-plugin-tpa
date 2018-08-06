<p align="center">
  <img src="docs/tpa_logo.png" />
</p>

# TPA plugin
[![Build Status](https://travis-ci.org/ThePerfectApp/fastlane-plugin-tpa.svg?branch=master)](https://travis-ci.org/ThePerfectApp/fastlane-plugin-tpa)
[![Gem](https://img.shields.io/gem/v/fastlane-plugin-tpa.svg?style=flat)](https://rubygems.org/gems/fastlane-plugin-tpa)
[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-tpa)

TPA gives you advanced user behaviour analytics, app distribution, crash analytics and more.

<p align="center">
  <a href="#getting-started">Getting Started</a> |
  <a href="#overview">Overview</a> |
  <a href="#issues-and-feedback">Issues and Feedback</a> |
  <a href="#license">License</a>
</p>

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-tpa`, add it to your project by running:

```bash
fastlane add_plugin tpa
```

## Overview

This plugin makes interacting with TPA easy by providing you actions to upload `.ipa`, `.apk` and `.dSYM` files directly to TPA.

In particular, this plugin provides the following two actions:

- [`tpa`](#tpa): uploads either an iOS `.ipa` app together with its corresponding `dSYM` to TPA. It is also capable of uploading an Android `.apk` app to TPA.
- [`upload_symbols_to_tpa`](#upload_symbols_to_tpa): Uploads only dSYM files to TPA

### tpa

Use the `tpa` action in order to upload an app to TPA. A common building lane would look something like the following:

```ruby
desc 'Builds a beta version of the app and uploads it to TPA'
lane :beta do
  build_app                  # Builds the app
  tpa                        # Uploads the app and dSYM files to TPA
end
```

### upload_symbols_to_tpa

If you have bitcode enabled in your iOS app, then you will need to download the `dSYM` files from App Store Connect and upload them to TPA so that the crash reports can be symbolicated. In order to help with this process, then you can make use of the `upload_symbols_to_tpa` action. 

This action should be part of the [`download_dsyms`](https://docs.fastlane.tools/actions/download_dsyms/) action which is part of Fastlane.

We recommend setting up a CI server which runs on a regular basis (for example once every night) to refresh the `dSYM` files. Such a lane could look like the following:

```ruby
desc 'Downloads the dSYM files from App Store Connect and uploads them to TPA'
lane :refresh_dsym do
  download_dsyms             # Download dSYM files from App Store Connect
  upload_symbols_to_tpa      # Upload them to TPA
  clean_build_artifacts      # Delete the local dSYM files
end
```

Instead of downloading all the dSYM files, then an alternative lane could look like the following:

```ruby
desc 'Downloads the dSYM files from App Store Connect and uploads them to TPA'
lane :refresh_dsym do
  download_dsyms(version: 'latest')    # Download dSYM files from App Store Connect
  upload_symbols_to_tpa                # Upload them to TPA
  clean_build_artifacts                # Delete the local dSYM files
end
```

## Available for `tpa.io` Domains
If you are using a managed version of TPA (for example `{your-subdomain.tpa.io}`, then feel free to use the latest version of this plugin. In your `Pluginfile` it should simply be written:

```ruby
gem 'fastlane-plugin-tpa'
```

If you do not have a `tpa.io` domain, you will need to use version 1.x.x of this plugin. You can install version 1.x.x by specifying the following in your `Pluginfile`:

```ruby
gem 'fastlane-plugin-tpa', '~>1.0'
```


## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`. 

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use 
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate building and releasing your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## License

MIT

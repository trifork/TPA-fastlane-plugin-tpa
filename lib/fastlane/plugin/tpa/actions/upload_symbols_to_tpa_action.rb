require 'fastlane/action'
require_relative '../helper/upload_symbols_to_tpa_helper'

module Fastlane
  module Actions
    class UploadSymbolsToTpaAction < Action
      def self.run(params)
        UI.message("The upload_symbols_to_tpa plugin is working!")
      end

      def self.description
        "Upload dsym files downloaded from iTunesConnect directly to TPA"
      end

      def self.authors
        ["Stefan Veis Pennerup"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "If your app uses Bitcode, then the final dsym files are not generated upon compile time. Instead you have to go to iTunesConnect and downloade the dsym files after Apple has processed your app. Afterwards you need to upload these files to TPA in order to allow for symbolication of the crash reports. You can use this plugin to streamline and automate this whole process."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "UPLOAD_SYMBOLS_TO_TPA_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end

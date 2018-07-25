require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UploadSymbolsToTpaHelper
      # Extracts the app identifier, version and build number from the dSYM path
      def self.parse_meta_data(path)
        # Extracts the app_identifier, version and build number from the path
        match_groups = File.basename(path).match("^(?<app_identifier>.+)-(?<version>.+)-(?<build>.+).dSYM.zip$")
        if match_groups.nil?
          raise "Failed to extract app identifier, version and build number from the #{path}"
        end
        return match_groups
      end
    end
  end
end

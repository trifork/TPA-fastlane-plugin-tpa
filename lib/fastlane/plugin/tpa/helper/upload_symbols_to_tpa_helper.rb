require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UploadSymbolsToTpaHelper
      # Extracts the TPA host name from the parameters
      def self.tpa_host(params)
        # Extracts the TPA host name from the upload_url using a regular expression
        match_groups = params[:upload_url].match("^(?<tpa_host>https:\/\/.*)\/.+\/upload$")
        if match_groups.nil?
          raise "Failed to extract TPA host from the provided upload url. Please double check that the given upload url is correct."
        end
        return match_groups[:tpa_host]
      end

      # Extracts the API UUID from the parameters
      def self.api_uuid(params)
        # Extracts the API UUID from the upload_url using a regular expression
        match_groups = params[:upload_url].match("^https:\/\/.*\/(?<api_uuid>.+)\/upload$")
        if match_groups.nil?
          raise "Failed to extract API UUID from the provided upload url. Please double check that the given upload url is correct."
        end
        return match_groups[:api_uuid]
      end

      # Extracts the app_identifier from the parameters
      def self.app_identifier(params)
        return params[:app_identifier]
      end
    end
  end
end

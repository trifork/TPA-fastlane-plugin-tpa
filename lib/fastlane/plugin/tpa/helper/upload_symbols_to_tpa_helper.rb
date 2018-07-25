require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UploadSymbolsToTpaHelper
      # class methods that you define here become available in your action
      # as `Helper::UploadSymbolsToTpaHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the upload_symbols_to_tpa plugin helper!")
      end
    end
  end
end

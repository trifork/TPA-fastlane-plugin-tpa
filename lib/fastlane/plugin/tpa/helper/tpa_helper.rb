module Fastlane
  module Helper
    class TpaHelper
      # class methods that you define here become available in your action
      # as `Helper::TpaHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the tpa plugin helper!")
      end
    end
  end
end

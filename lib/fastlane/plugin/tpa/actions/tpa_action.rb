module Fastlane
  module Actions
    require_relative 'upload_to_tpa_action'
    class TpaAction < UploadToTpaAction
      def self.description
        "Alias for the `upload_to_tpa` action"
      end
    end
  end
end

module Fastlane
  module Helper
    class TpaHelper
      # Specifies a list of ConfigItems that all the actions have as available options
      def self.shared_available_options
        [
          FastlaneCore::ConfigItem.new(key: :base_url,
                                       env_name: "FL_TPA_BASE_URL",
                                       description: "The Base URL for your TPA",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("The Base URL cannot be empty") if value.to_s.length.zero?
                                         UI.user_error!("Please specify a Base URL beginning with https://") unless value.start_with?("https://")
                                         UI.user_error!("Please specify a Base URL which ends with .tpa.io") unless value.end_with?(".tpa.io", ".tpa.io/")
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_uuid,
                                       env_name: "FL_TPA_API_UUID",
                                       description: "The API UUID of your TPA project",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("The API UUID cannot be empty") if value.to_s.length.zero?
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_TPA_API_KEY",
                                       description: "Your API key to access the TPA REST API",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("The API key cannot be empty") if value.to_s.length.zero?
                                       end)
        ]
      end
    end
  end
end

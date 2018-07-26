module Fastlane
  module Helper
    class TpaHelper
      # Specifies a list of ConfigItems that all the actions have as available options
      def self.shared_available_options
        [
          FastlaneCore::ConfigItem.new(key: :tpa_host,
                                       env_name: "FL_TPA_HOST_URL",
                                       description: "The TPA host url",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("The TPA host cannot be empty") if value.to_s.length.zero?
                                         UI.user_error!("Please specify a host name beginning with https://") unless value.start_with?("https://")
                                         UI.user_error!("Please specify a host name which ends with .tpa.io") unless value.end_with?(".tpa.io", ".tpa.io/")
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_uuid,
                                       env_name: "FL_TPA_API_UUID",
                                       description: "The API UUID of the project",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("The TPA API UUID cannot be empty") if value.to_s.length.zero?
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_TPA_API_KEY",
                                       description: "An API key to TPA",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("The TPA API key cannot be empty") if value.to_s.length.zero?
                                       end)
        ]
      end
    end
  end
end

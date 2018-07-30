module Fastlane
  module Actions
    class TpaAction < Action
      def self.run(params)
        require 'rest_client'

        upload_url = upload_url(params)
        headers = headers(params)
        body = body(params)

        UI.message("Going to upload app to TPA")
        UI.success("This might take a few minutes. Please don't interrupt the script.")

        # Starts the upload
        begin
          RestClient.post(upload_url, body, headers)
        rescue RestClient::ExceptionWithResponse => ex
          handle_exception_response(ex)
        rescue => ex
          UI.crash!("4Something went wrong while uploading your app to TPA: #{ex}")
        else
          UI.success("🎉 Your app has successfully been uploaded to TPA 🎉")
        end
      end

      def self.app_file(params)
        app_file = [
          params[:ipa],
          params[:apk]
        ].detect { |e| !e.to_s.empty? }

        if app_file.nil?
          UI.user_error!("You have to provide a build file")
        end

        app_file
      end

      def self.upload_url(params)
        "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      end

      def self.headers(params)
        {
          :"X-API-Key" => params[:api_key]
        }
      end

      def self.body(params)
        {
          app: File.new(app_file(params), 'rb'),
          mapping: params[:mapping],
          notes: params[:notes],
          publish: params[:publish],
          force: params[:force]
        }
      end

      def self.handle_exception_response(ex)
        if Fastlane::Helper::TpaHelper.valid_json?(ex.response)
          res = JSON.parse(ex.response)
          if res.key?("detail")
            UI.crash!("Something went wrong while uploading your app to TPA: #{res['detail']}")
          else
            UI.crash!("Something went wrong while uploading your app to TPA: #{res}")
          end
        else
          UI.crash!("Something went wrong while uploading your app to TPA: #{ex.response}")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload app builds to The Perfect App (tpa.io)"
      end

      def self.details
        [
          "This plugin helps you to easily setup a CI/CD integration with The Perfect App. Simply",
          "install this plugin and add the `tpa` command to your normal building lane. This will guide",
          "you through the necessary parameters to use this plugin, which we recommend setting up as",
          " as environmental to automate the whole process."
        ].join(" ")
      end

      def self.available_options
        Fastlane::Helper::TpaHelper.shared_available_options + [
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "FL_TPA_IPA",
                                       description: "Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:apk],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                       end),
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: "FL_TPA_APK",
                                       description: "Path to your APK file",
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:ipa],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'apk' and '#{value.key}' options in one run")
                                       end),
          FastlaneCore::ConfigItem.new(key: :mapping,
                                       env_name: "FL_TPA_MAPPING",
                                       description: "Path to your symbols file. For iOS provide path to app.dSYM.zip. For Android provide path to mappings.txt file",
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         # validation is done in the action
                                       end),
          FastlaneCore::ConfigItem.new(key: :publish,
                                       env_name: "FL_TPA_PUBLISH",
                                       description: "Publish build upon upload",
                                       default_value: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_TPA_FORCE",
                                       description: "Should a version with the same number already exist, force the new app to take the place of the old one",
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :notes,
                                       env_name: "FL_TPA_NOTES",
                                       description: "Release notes",
                                       optional: true)
        ]
      end

      def self.output
        nil
      end

      def self.return_value
        nil
      end

      def self.authors
        ["mbogh", "Stefan Veis Pennerup"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

      def self.example_code
        [
          'tpa'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end

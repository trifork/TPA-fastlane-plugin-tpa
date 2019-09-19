module Fastlane
  module Actions
    module SharedValues
      # Direct installation URL to the uploaded app
      TPA_INSTALL_URL = :TPA_INSTALL_URL
      # URL to tpa.io where you can see (and download) the app
      TPA_BUILD_URL = :TPA_BUILD_URL
    end

    class UploadToTpaAction < Action
      def self.run(params)
        require 'rest_client'

        upload_url = upload_url(params)
        headers = headers(params)
        body = body(params)

        UI.success("🚀 Uploading app to TPA 🚀")
        UI.important("This might take a few minutes. Please don't interrupt the script. 🚀")

        # Starts the upload
        begin
          response = RestClient.post(upload_url, body, headers)
          if Fastlane::Helper::TpaHelper.valid_json?(response)
            res = JSON.parse(response)
            app_name = res["name"]
            version = res["version_string"]
            build_number = res["version_number"]
            build_url = res["build_url"]
            install_url = res["install_url"]
            Actions.lane_context[SharedValues::TPA_INSTALL_URL] = install_url
            Actions.lane_context[SharedValues::TPA_BUILD_URL] = build_url
            UI.success("🎉 #{app_name} version #{version} (#{build_number}) has successfully been uploaded to TPA 🎉")
          else
            UI.abort_with_message!("Something went wrong while uploading your app to TPA")
          end
        rescue RestClient::ExceptionWithResponse => ex
          handle_exception_response(ex)
        rescue => ex
          UI.abort_with_message!("Something went wrong while uploading your app to TPA: #{ex}")
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
        body = {
          app: File.new(app_file(params), 'rb'),
          notes: params[:notes],
          publish: params[:publish],
          force: params[:force]
        }

        # Only set mapping key if mapping file exists.
        # Even setting a nil value will cause Fastlane to send an empty value causing an error.
        unless params[:mapping].nil?
          case params[:mapping]
          when String
            if File.exist?(params[:mapping])
              body[:mapping] = File.new(params[:mapping], 'rb')
            end
          when Array
            mapping_files = []
            params[:mapping].each do |mapping|
              if File.exist?(mapping)
                mapping_files.push(File.new(mapping, 'rb'))
              else
                UI.message("Unable to find mapping file at #{mapping}")
              end
            end
            unless mapping_files.empty?
              body[:mapping] = mapping_files
            end
          else
            UI.user_error!("Specified mapping files do not exists.")
          end
        end

        body
      end

      def self.handle_exception_response(ex)
        if Fastlane::Helper::TpaHelper.valid_json?(ex.response)
          res = JSON.parse(ex.response)
          if res.key?("detail")
            UI.abort_with_message!("Something went wrong while uploading your app to TPA: #{res['detail']}")
          else
            UI.abort_with_message!("Something went wrong while uploading your app to TPA: #{res}")
          end
        else
          UI.abort_with_message!("Something went wrong while uploading your app to TPA: #{ex.response}")
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
                                       description: "Path to your symbols files. For iOS provide path to app.dSYM.zip. For Android provide path to mappings.txt file. For React-Native also provide paths to your source-maps",
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH],
                                       optional: true,
                                       is_string: false,
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
        ["mbogh", "Stefan Veis Pennerup", "madsbogeskov"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

      def self.example_code
        [
          'upload_to_tpa'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end

describe Fastlane::Actions::UploadToTpaAction do
  describe "The action" do
    let(:fixtures_path) { File.expand_path("./spec/fixtures") }
    let(:ipa_file) { File.join(fixtures_path, 'file.ipa') }
    let(:apk_file) { File.join(fixtures_path, 'file.apk') }

    it "is able to handle a non-JSON response if the network request fails" do
      # Sets up the params
      params = {
        base_url: "https://someproject.tpa.io",
        api_uuid: "some-very-special-uuid",
        ipa: ipa_file
      }

      # Sets up the stub
      url = "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      body = "Something went horribly wrong"
      stub_request(:post, url).to_return(body: body, status: 403)

      # Runs the action
      expect do
        Fastlane::Actions::UploadToTpaAction.run(params)
      end.to raise_exception("Something went wrong while uploading your app to TPA: #{body}")
    end

    it "parses the \"detail\" parameter if the network request fails" do
      # Sets up the params
      params = {
        base_url: "https://someproject.tpa.io",
        api_uuid: "some-very-special-uuid",
        ipa: ipa_file
      }

      # Sets up the stub
      url = "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      body = "{\"detail\": \"Something went wrong\"}"
      stub_request(:post, url).to_return(body: body, status: 403)

      # Runs the action
      expect do
        Fastlane::Actions::UploadToTpaAction.run(params)
      end.to raise_exception("Something went wrong while uploading your app to TPA: Something went wrong")
    end

    it "upload url is returned correctly" do
      params = {
        base_url: "https://someproject.tpa.io",
        api_uuid: "some-very-special-uuid"
      }
      url = "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      expect(Fastlane::Actions::UploadToTpaAction.upload_url(params)).to eq(url)
    end

    it "should force upload, overriding existing build" do
      # Tests if the force key is empty
      params = {
        ipa: ipa_file
      }
      body = Fastlane::Actions::UploadToTpaAction.body(params)
      expect(body[:force]).to eq(nil)

      # Tests if the force key is true
      params = {
        ipa: ipa_file,
        force: true
      }
      body = Fastlane::Actions::UploadToTpaAction.body(params)
      expect(body[:force]).to eq(true)
    end

    it "should include mapping file if added" do
      # Tests if the mapping flag is empty
      params = {
        ipa: ipa_file
      }
      body = Fastlane::Actions::UploadToTpaAction.body(params)
      expect(body[:mapping]).to eq(nil)

      # Tests if the mapping key is set
      params = {
        ipa: ipa_file,
        mapping: './spec/fixtures/file.dSYM.zip'
      }
      body = Fastlane::Actions::UploadToTpaAction.body(params)
      expect(File.path(body[:mapping])).to eq('./spec/fixtures/file.dSYM.zip')
    end

    it "supports Android as well" do
      params = {
        apk: apk_file
      }
      body = Fastlane::Actions::UploadToTpaAction.body(params)
      expect(File.absolute_path(body[:app])).to eq(apk_file)
    end

    it "does not allow both ipa and apk at the same time" do
      file_path_apk = apk_file
      FileUtils.touch(file_path_apk)

      file_path_ipa = ipa_file
      FileUtils.touch(file_path_ipa)

      expect do
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(apk: '#{apk_file}',
              ipa: '#{ipa_file}',
              base_url: 'https://my.tpa.io',
              api_uuid: 'xxx-yyy-zz',
              api_key: '12345678')
        end").runner.execute(:test)
      end.to raise_exception("You can't use 'apk' and 'ipa' options in one run")

      expect do
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(ipa: '#{ipa_file}',
              apk: '#{apk_file}',
              base_url: 'https://my.tpa.io',
              api_uuid: 'xxx-yyy-zz',
              api_key: '12345678')
        end").runner.execute(:test)
      end.to raise_exception("You can't use 'ipa' and 'apk' options in one run")
    end

    it "raises an error if no app is provided" do
      expect do
        ENV['IPA_OUTPUT_PATH'] = nil
        ENV['GRADLE_APK_OUTPUT_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GRADLE_APK_OUTPUT_PATH] = nil

        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(base_url: 'https://my.tpa.io',
              api_uuid: 'xxx-yyy-zz',
              api_key: '12345678')
        end").runner.execute(:test)
      end.to raise_exception("You have to provide a build file")
    end

    it "correctly updates lane_context with values from response" do
      # Sets up the params
      params = {
          base_url: "https://someproject.tpa.io",
          api_uuid: "some-very-special-uuid",
          ipa: ipa_file
      }

      build_url = "https://build-url.com"
      install_url = "https://install-url.com"

      # Sets up the stub
      url = "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      body = "{\"build_url\":\"#{build_url}\", \"install_url\":\"#{install_url}\"}"
      stub_request(:post, url).to_return(body: body, status: 200)

      Fastlane::Actions::UploadToTpaAction.run(params)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::TPA_BUILD_URL]).to eq(build_url)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::TPA_INSTALL_URL]).to eq(install_url)
    end

    describe "Meta data" do
      it "contains a description" do
        expect(Fastlane::Actions::UploadToTpaAction.description.empty?).to eq(false)
      end

      it "contains details" do
        expect(Fastlane::Actions::UploadToTpaAction.details.empty?).to eq(false)
      end

      # TODO: Test available options

      it "does not have an output" do
        expect(Fastlane::Actions::UploadToTpaAction.output).to eq(nil)
      end

      it "does not have a return_value" do
        expect(Fastlane::Actions::UploadToTpaAction.return_value).to eq(nil)
      end

      it "mentions an author" do
        expect(Fastlane::Actions::UploadToTpaAction.authors.empty?).to eq(false)
        expect(Fastlane::Actions::UploadToTpaAction.authors.first.empty?).to eq(false)
      end

      it "supports iOS" do
        expect(Fastlane::Actions::UploadToTpaAction.is_supported?(:ios)).to eq(true)
      end

      it "supports Android" do
        expect(Fastlane::Actions::UploadToTpaAction.is_supported?(:android)).to eq(true)
      end

      it "provides example code" do
        expect(Fastlane::Actions::UploadToTpaAction.example_code.empty?).to eq(false)
        expect(Fastlane::Actions::UploadToTpaAction.example_code.first.empty?).to eq(false)
      end

      it "specifies a category" do
        expect(Fastlane::Actions::UploadToTpaAction.category).to eq(:beta)
      end
    end
  end

  describe "The helper" do
    it 'contains the shared ConfigItems' do
      options = Fastlane::Helper::TpaHelper.shared_available_options
      expect(options.size).to eq(3)
      option_names = options.map(&:key)
      expect(option_names).to include(:base_url)
      expect(option_names).to include(:api_uuid)
      expect(option_names).to include(:api_key)
    end
  end
end

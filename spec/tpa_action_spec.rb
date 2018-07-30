describe Fastlane::Actions::TpaAction do
  describe "The action" do
    it "is able to handle a non-JSON response if the network request fails" do
      # Sets up the params
      params = {
        base_url: "https://someproject.tpa.io",
        api_uuid: "some-very-special-uuid",
        ipa: '/tmp/file.ipa'
      }

      # Sets up the stub
      url = "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      body = "Something went horribly wrong"
      stub_request(:post, url).to_return(body: body, status: 403)

      # Runs the action
      expect do
        Fastlane::Actions::TpaAction.run(params)
      end.to raise_exception("Something went wrong while uploading your app to TPA: #{body}")
    end

    it "parses the \"detail\" parameter if the network request fails" do
      # Sets up the params
      params = {
        base_url: "https://someproject.tpa.io",
        api_uuid: "some-very-special-uuid",
        ipa: '/tmp/file.ipa'
      }

      # Sets up the stub
      url = "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      body = "{\"detail\": \"Something went wrong\"}"
      stub_request(:post, url).to_return(body: body, status: 403)

      # Runs the action
      expect do
        Fastlane::Actions::TpaAction.run(params)
      end.to raise_exception("Something went wrong while uploading your app to TPA: Something went wrong")
    end

    it "upload url is returned correctly" do
      params = {
        base_url: "https://someproject.tpa.io",
        api_uuid: "some-very-special-uuid"
      }
      url = "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      expect(Fastlane::Actions::TpaAction.upload_url(params)).to eq(url)
    end

    it "should force upload, overriding existing build" do
      # Tests if the force key is empty
      params = {
        ipa: '/tmp/file.ipa'
      }
      body = Fastlane::Actions::TpaAction.body(params)
      expect(body[:force]).to eq(nil)

      # Tests if the force key is true
      params = {
        ipa: '/tmp/file.ipa',
        force: true
      }
      body = Fastlane::Actions::TpaAction.body(params)
      expect(body[:force]).to eq(true)
    end

    it "should include mapping file if added" do
      # Tests if the mapping flag is empty
      params = {
        ipa: '/tmp/file.ipa'
      }
      body = Fastlane::Actions::TpaAction.body(params)
      expect(body[:force]).to eq(nil)

      # Tests if the mapping key is set
      params = {
        ipa: '/tmp/file.ipa',
        mapping: '/tmp/file.dSYM.zip'
      }
      body = Fastlane::Actions::TpaAction.body(params)
      expect(body[:mapping]).to eq('/tmp/file.dSYM.zip')
    end

    it "supports Android as well" do
      params = {
        apk: '/tmp/file.apk'
      }
      body = Fastlane::Actions::TpaAction.body(params)
      expect(File.absolute_path(body[:app])).to eq('/tmp/file.apk')
    end

    it "does not allow both ipa and apk at the same time" do
      file_path_apk = '/tmp/file.apk'
      FileUtils.touch(file_path_apk)

      file_path_ipa = '/tmp/file.ipa'
      FileUtils.touch(file_path_ipa)

      expect do
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(apk: '/tmp/file.apk',
              ipa: '/tmp/file.ipa',
              base_url: 'https://my.tpa.io',
              api_uuid: 'xxx-yyy-zz',
              api_key: '12345678')
        end").runner.execute(:test)
      end.to raise_exception("You can't use 'apk' and 'ipa' options in one run")

      expect do
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(ipa: '/tmp/file.ipa',
              apk: '/tmp/file.apk',
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

    describe "Meta data" do
      it "contains a description" do
        expect(Fastlane::Actions::TpaAction.description.empty?).to eq(false)
      end

      it "contains details" do
        expect(Fastlane::Actions::TpaAction.details.empty?).to eq(false)
      end

      # TODO: Test available options

      it "does not have an output" do
        expect(Fastlane::Actions::TpaAction.output).to eq(nil)
      end

      it "does not have a return_value" do
        expect(Fastlane::Actions::TpaAction.return_value).to eq(nil)
      end

      it "mentions an author" do
        expect(Fastlane::Actions::TpaAction.authors.empty?).to eq(false)
        expect(Fastlane::Actions::TpaAction.authors.first.empty?).to eq(false)
      end

      it "supports iOS" do
        expect(Fastlane::Actions::TpaAction.is_supported?(:ios)).to eq(true)
      end

      it "supports Android" do
        expect(Fastlane::Actions::TpaAction.is_supported?(:android)).to eq(true)
      end

      it "provides example code" do
        expect(Fastlane::Actions::TpaAction.example_code.empty?).to eq(false)
        expect(Fastlane::Actions::TpaAction.example_code.first.empty?).to eq(false)
      end

      it "specifies a category" do
        expect(Fastlane::Actions::TpaAction.category).to eq(:beta)
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

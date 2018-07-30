describe Fastlane::Actions::TpaAction do
  describe "The action" do
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

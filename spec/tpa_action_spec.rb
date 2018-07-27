describe Fastlane::Actions::TpaAction do
  describe "The Perfect App integration" do
    it "verbosity is set correctly" do
      expect(Fastlane::Actions::TpaAction.verbose(verbose: true)).to eq("--verbose")
      expect(Fastlane::Actions::TpaAction.verbose(verbose: false)).to eq("--silent")
      expect(Fastlane::Actions::TpaAction.verbose(verbose: false, progress_bar: true)).to eq(nil)
    end

    it "upload url is returned correctly" do
      params = {
        base_url: "https://someproject.tpa.io",
        api_uuid: "some-very-special-uuid"
      }
      url = "#{params[:base_url]}/rest/api/v2/projects/#{params[:api_uuid]}/apps/versions/app/"
      expect(Fastlane::Actions::TpaAction.upload_url(params)).to eq(url)
    end

    it "raises an error if result is not 'OK'" do
      result = "Not enough fish"

      expect do
        Fastlane::Actions::TpaAction.fail_on_error(result)
      end.to raise_exception("Something went wrong while uploading your app to TPA: #{result}")
    end

    it "does not raise an error if result is '201'" do
      result = "| http_status 201"

      expect do
        Fastlane::Actions::TpaAction.fail_on_error(result)
      end.to_not(raise_exception)
    end

    it "mandatory options are used correctly" do
      ENV['DSYM_OUTPUT_PATH'] = nil
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil

      file_path = '/tmp/file.ipa'
      FileUtils.touch(file_path)
      result = Fastlane::FastFile.new.parse("lane :test do
        tpa(ipa: '/tmp/file.ipa',
            base_url: 'https://my.tpa.io',
            api_uuid: 'xxx-yyy-zz',
            api_key: '12345678')
      end").runner.execute(:test)

      expect(result).to include("-F app=@\"/tmp/file.ipa\"")
      expect(result).to include("-F publish=true")
      expect(result).to include("-F force=false")
      expect(result).not_to(include("--silent")) # Do not include silent because of progress-bar
      expect(result).to include("--progress-bar")
      expect(result).to include("https://my.tpa.io/rest/api/v2/projects/xxx-yyy-zz/apps/versions/app/")
    end

    it "should include release notes if provided" do
      file_path = '/tmp/file.ipa'
      FileUtils.touch(file_path)
      result = Fastlane::FastFile.new.parse("lane :test do
        tpa(ipa: '/tmp/file.ipa',
            base_url: 'https://my.tpa.io',
            api_uuid: 'xxx-yyy-zz',
            api_key: '12345678',
            notes: 'Now with iMessages extension a.k.a stickers for everyone!')
      end").runner.execute(:test)

      expect(result).to include("-F notes=Now with iMessages extension a.k.a stickers for everyone!")
    end

    it "should publish" do
      file_path = '/tmp/file.ipa'
      FileUtils.touch(file_path)
      result = Fastlane::FastFile.new.parse("lane :test do
        tpa(ipa: '/tmp/file.ipa',
            base_url: 'https://my.tpa.io',
            api_uuid: 'xxx-yyy-zz',
            api_key: '12345678',
            publish: true)
      end").runner.execute(:test)

      expect(result).to include("-F publish=true")
    end

    it "should respect progress_bar false" do
      file_path = '/tmp/file.ipa'
      FileUtils.touch(file_path)
      result = Fastlane::FastFile.new.parse("lane :test do
        tpa(ipa: '/tmp/file.ipa',
            base_url: 'https://my.tpa.io',
            api_uuid: 'xxx-yyy-zz',
            api_key: '12345678',
            progress_bar: false)
      end").runner.execute(:test)

      expect(result).not_to(include("--progress-bar"))
      expect(result).to include("--silent")
    end

    it "should force upload, overriding existing build" do
      file_path = '/tmp/file.ipa'
      FileUtils.touch(file_path)
      result = Fastlane::FastFile.new.parse("lane :test do
        tpa(ipa: '/tmp/file.ipa',
            base_url: 'https://my.tpa.io',
            api_uuid: 'xxx-yyy-zz',
            api_key: '12345678',
            force: true)
      end").runner.execute(:test)

      expect(result).to include("-F force=true")
    end

    it "should include mapping file if added" do
      file_path = '/tmp/file.ipa'
      FileUtils.touch(file_path)
      result = Fastlane::FastFile.new.parse("lane :test do
        tpa(ipa: '/tmp/file.ipa',
            base_url: 'https://my.tpa.io',
            api_uuid: 'xxx-yyy-zz',
            api_key: '12345678',
            mapping: '/tmp/file.dSYM.zip')
      end").runner.execute(:test)

      expect(result).to include("-F mapping=@\"/tmp/file.dSYM.zip\"")
    end

    it "supports Android as well" do
      file_path = '/tmp/file.apk'
      FileUtils.touch(file_path)
      result = Fastlane::FastFile.new.parse("lane :test do
        tpa(apk: '/tmp/file.apk',
            base_url: 'https://my.tpa.io',
            api_uuid: 'xxx-yyy-zz',
            api_key: '12345678')
      end").runner.execute(:test)

      expect(result).to include("-F app=@\"/tmp/file.apk\"")
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
end

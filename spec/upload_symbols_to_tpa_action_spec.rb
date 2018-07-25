describe Fastlane::Actions::UploadSymbolsToTpaAction do
  describe 'The action' do
    it 'makes mbogh happy 🎉' do
      expect(true)
    end

    it 'uploads a new dSYM file' do
      # Specifies the parameters. None are required for this test case
      params = {}

      # Specifies a list of known dSYM files already uploaded to TPA
      known_dsyms = [
        { "version_number" => "79", "hash" => "92e914888c834bf9f1b7d171c907ebb1", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-79.dSYM.zip" },
        { "version_number" => "81", "hash" => "557ccb69647bc7411f22bee61b552162", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-81.dSYM.zip" },
        { "version_number" => "80", "hash" => "f932fa694bec6c7973a958814fb8346c", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-80.dSYM.zip" },
        { "version_number" => "82", "hash" => "f91eb2604797cd90b936e31fe789d219", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-82.dSYM.zip" }
      ]

      # Creates a fake temporary dSYM file to compare against
      dsym_path = '/tmp/com.theperfectapp.Awesome-App-1.0-78.dSYM.zip'
      FileUtils.touch dsym_path

      # Performs the test
      should_upload = Fastlane::Actions::UploadSymbolsToTpaAction.should_upload_dsym(params, known_dsyms, dsym_path)
      expect(should_upload).to eq true
    end

    it 'does not upload an already uploaded dSYM file' do
      # Specifies the parameters. None are required for this test case
      params = {}

      # Specifies a list of known dSYM files already uploaded to TPA
      known_dsyms = [
        { "version_number" => "78", "hash" => "d41d8cd98f00b204e9800998ecf8427e", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-78.dSYM.zip" },
        { "version_number" => "79", "hash" => "92e914888c834bf9f1b7d171c907ebb1", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-79.dSYM.zip" },
        { "version_number" => "81", "hash" => "557ccb69647bc7411f22bee61b552162", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-81.dSYM.zip" },
        { "version_number" => "80", "hash" => "f932fa694bec6c7973a958814fb8346c", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-80.dSYM.zip" },
        { "version_number" => "82", "hash" => "f91eb2604797cd90b936e31fe789d219", "version_string" => "1.0", "filename" => "com.theperfectapp.Awesome-App-1.0-82.dSYM.zip" }
      ]

      # Creates a fake temporary dSYM file to compare against
      dsym_path = '/tmp/com.theperfectapp.Awesome-App-1.0-78.dSYM.zip'
      FileUtils.touch dsym_path

      # Performs the test
      should_upload = Fastlane::Actions::UploadSymbolsToTpaAction.should_upload_dsym(params, known_dsyms, dsym_path)
      expect(should_upload).to eq false
    end
  end

  describe 'The helper' do
    it 'extracts the app identifier, version string and build number from the dSYM file path' do
      dsym_path = '/tmp/com.theperfectapp.Awesome-App-1.0-78.dSYM.zip'
      meta_data = Fastlane::Helper::UploadSymbolsToTpaHelper.parse_meta_data(dsym_path)
      expect(meta_data[:app_identifier]).to eq 'com.theperfectapp.Awesome-App'
      expect(meta_data[:version]).to eq '1.0'
      expect(meta_data[:build]).to eq '78'
    end
  end
end

describe Fastlane::Actions::UploadSymbolsToTpaAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The upload_symbols_to_tpa plugin is working!")

      Fastlane::Actions::UploadSymbolsToTpaAction.run(nil)
    end
  end
end

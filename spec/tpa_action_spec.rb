describe Fastlane::Actions::TpaAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The tpa plugin is working!")

      Fastlane::Actions::TpaAction.run(nil)
    end
  end
end

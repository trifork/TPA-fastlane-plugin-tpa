describe Fastlane::Actions::TpaAction do
  describe "The action" do
    it "should alias upload_to_tpa" do
      expect(Fastlane::Actions::TpaAction < Fastlane::Actions::UploadToTpaAction).to eq(true)
    end
  end
end

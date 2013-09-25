require 'spec_helper'

feature "Preparing a Stats Selector document" do
  describe "making a new selector" do
    UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

    specify "visiting the new selector path currently creates a selector for you" do
      visit "/selectors/new"

      expect(page.current_path).to match(%r{^/selectors/(.*)})
      expect(
        %r{^/selectors/(.*)}.match(page.current_path)[1]
      ).to match(UUID_REGEX)
    end
  end
end
# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/DescribeClass
describe "Admin adds integrations on proposals component" do
  # rubocop:enable RSpec/DescribeClass
  include_context "with a component"
  let!(:manifest_name) { "proposals" }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  context "when dataspace is disabled" do
    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit decidim_admin_participatory_processes.components_path(participatory_process)
      within ".component-#{component.id}" do
        find("a[title='Configure']").click
      end
    end

    it "doesn't display the fields related to it" do
      expect(page).to have_no_css("div.add_integration_container")
      expect(page).to have_no_css("div.integration_url_container")
      expect(page).to have_no_css("div.preferred_locale_container")
    end
  end

  context "when dataspace is enabled" do
    before do
      component.organization.enable_dataspace = true
      component.organization.save!
    end

    context "when editing the proposals component" do
      before do
        switch_to_host(organization.host)
        login_as admin, scope: :user
        visit decidim_admin_participatory_processes.components_path(participatory_process)
        within ".component-#{component.id}" do
          find("a[title='Configure']").click
        end
      end

      context "and adding valid urls" do
        it "can adds multiple integrations and updates component" do
          # check add integration displays 2 divs
          check I18n.t("decidim.components.proposals.settings.global.add_integration")
          expect(page).to have_css("div.integration_url_container")
          expect(page).to have_css("div.preferred_locale_container")
          # provide valid urls, no error message displayed
          fill_in "component[settings][integration_url]", with: "http://example.com, http://localhost:3000"
          expect(page).to have_no_css("p.url_input_error")
          select("fr", from: "component[settings][preferred_locale]")
          # update component succesfully
          click_link_or_button "Update"
          expect(page).to have_content("The component was updated successfully.")
        end
      end

      context "and adding invalid url" do
        it "gets an error message" do
          check I18n.t("decidim.components.proposals.settings.global.add_integration")
          # provide invalid url
          fill_in "component[settings][integration_url]", with: "http://localhost:3000, example.com"
          # error message displayed when input looses focus
          find_by_id("component_settings_preferred_locale").click
          sleep(1)
          expect(page).to have_css("p.url_input_error")
          # providing a good url removes the error
          fill_in "component[settings][integration_url]", with: "http://localhost:3000, http://example.com"
          # error message removed when input looses focus
          find_by_id("component_settings_preferred_locale").click
          sleep(1)
          expect(page).to have_no_css("p.url_input_error")
        end
      end
    end
  end
end

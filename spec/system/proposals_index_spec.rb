# frozen_string_literal: true

require "spec_helper"

describe "Proposals" do
  include ActionView::Helpers::TextHelper
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:scope) { create(:scope, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization:, scope:) }

  let(:proposal_title) { translated(proposal.title) }

  context "when listing proposals in a participatory process" do
    shared_examples_for "a random proposal ordering" do
      let!(:lucky_proposal) { create(:proposal, component:) }
      let!(:unlucky_proposal) { create(:proposal, component:) }
      let!(:lucky_proposal_title) { translated(lucky_proposal.title) }
      let!(:unlucky_proposal_title) { translated(unlucky_proposal.title) }

      it "lists the proposals ordered randomly by default" do
        visit_component

        expect(page).to have_css("a", text: "Random")
        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        expect(page).to have_css("[id^='proposals__proposal']", text: lucky_proposal_title)
        expect(page).to have_css("[id^='proposals__proposal']", text: unlucky_proposal_title)
        expect(page).to have_author(lucky_proposal.creator_author.name)
      end
    end

    context "when there is no external proposals" do
      it "lists all the proposals" do
        create(:proposal_component,
               manifest:,
               participatory_space: participatory_process)

        create_list(:proposal, 3, component:)

        visit_component
        # only proposals
        expect(page).to have_css("a[class='card__list']", count: 3)
        expect(page).to have_css("[id^='proposals__proposal']", count: 3)
      end
    end

    context "and there are external proposals" do
      let(:json) do
        { "contributions" => [{ "reference" => "JD-PROP-2025-09-1",
                                "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
                                "container" => "JD-PART-2025-09-1",
                                "locale" => "en",
                                "title" => "Test one",
                                "content" => "Debitis repellat provident",
                                "authors" => ["JD-MEET-2025-09-6"],
                                "created_at" => "2025-09-11T10:20:21.222Z",
                                "updated_at" => "2025-09-11T10:21:56.604Z",
                                "deleted_at" => nil },
                              { "reference" => "JD-PROP-2025-09-20",
                                "source" => "http://localhost:3000/assemblies/smile-trivial/f/25/proposals/20",
                                "container" => "JD-ASSE-2025-09-1",
                                "locale" => "en",
                                "title" => "Test two",
                                "content" => "Non et vel",
                                "authors" => ["JD-MEET-2025-09-23"],
                                "created_at" => "2025-09-11T10:43:23.743Z",
                                "updated_at" => "2025-09-11T10:43:27.147Z",
                                "deleted_at" => nil }] }
      end

      before do
        create(:proposal_component, manifest:, participatory_space: participatory_process)
        create_list(:proposal, 3, component:)
        component.update!(settings: { add_integration: true, integration_url: "http://example.org" })
        allow(GetDataFromApi).to receive(:contributions).and_return(json)
      end

      it "lists the proposals ordered randomly by default and the external proposals at the end" do
        visit_component
        # 5 cards
        expect(page).to have_css("a[class='card__list']", count: 5)
        # 3 proposals
        expect(page).to have_css("[id^='proposals__proposal']", count: 3)
        # 2 external proposals
        expect(page).to have_css("[id='JD-PROP-2025-09-1']", count: 1)
        expect(page).to have_css("[id='JD-PROP-2025-09-20']", count: 1)
      end

      context "and there are a lot of proposals" do
        before do
          # Decidim::Paginable::OPTIONS.first is 25
          create_list(:proposal, Decidim::Paginable::OPTIONS.first, component:)
          # we have already create 3 proposals, so we will have a total of 28 proposals
        end

        it "paginates them with proposals first and external proposals at the end" do
          visit_component
          # only proposals on first page
          expect(page).to have_css("a[class='card__list']", count: Decidim::Paginable::OPTIONS.first)
          expect(page).to have_css("[id^='proposals__proposal']", count: Decidim::Paginable::OPTIONS.first)

          click_on "Next"
          # proposals and external proposals on second page
          expect(page).to have_css("a[class='card__list']", count: 5)
          expect(page).to have_css("[data-pages] [data-page][aria-current='page']", text: "2")
          expect(page).to have_css("[id^='proposals__proposal']", count: 3)
          expect(page).to have_css("[id='JD-PROP-2025-09-1']", count: 1)
          expect(page).to have_css("[id='JD-PROP-2025-09-20']", count: 1)
        end
      end
    end
  end
end

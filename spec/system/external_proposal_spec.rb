# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/DescribeClass
describe "Proposals external proposal" do
  # rubocop:enable RSpec/DescribeClass
  include_context "with a component"
  let!(:manifest_name) { "proposals" }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:proposal_component, participatory_space: participatory_process) }

  let(:authors) do
    [
      {
        "reference" => "JD-MEET-2025-09-23",
        "name" => "Et natus.",
        "source" => "http://localhost:3000/assemblies/smile-trivial/f/23/meetings/23"
      },
      {
        "reference" => "Aldo Davis",
        "name" => "Aldo Davis",
        "source" => nil
      },
      {
        "reference" => "Kautzer-Mayer",
        "name" => "Kautzer-Mayer",
        "source" => nil
      },
      {
        "reference" => "JD",
        "name" => "Gislason LLC",
        "source" => nil
      }
    ]
  end

  before do
    component.update!(settings: { add_integration: true, integration_url: "http://example.org", preferred_locale: "en" })
    allow(GetDataFromApi).to receive(:contribution).and_return(json_contrib)
    allow(GetDataFromApi).to receive(:authors).and_return(authors)
    visit_external_proposal
  end

  context "when the external proposal has no comments" do
    let(:json_contrib) do
      {
        "reference" => "JD-PROP-2025-09-1",
        "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
        "container" => "JD-PART-2025-09-1",
        "locale" => "en",
        "title" => "Quia sapiente.",
        "content" => "Debitis repellat provident. Earum dolorem eaque. Aut quia officiis.",
        "authors" => [
          "Aldo Davis"
        ],
        "parent" => nil,
        "children" => nil,
        "metadata" => {
          "state" => {
            "withdrawn" => false,
            "emendation" => false,
            "state" => "accepted"
          }
        },
        "created_at" => "2025-09-11T10:20:21.222Z",
        "updated_at" => "2025-09-11T10:21:56.604Z",
        "deleted_at" => nil
      }
    end

    it "displays only external proposal" do
      expect(page).to have_css("h1", text: "Quia sapiente.")
      expect(page).to have_css("p.author_name", text: "Aldo Davis")
      expect(page).to have_css("div.rich-text-display", text: json_contrib["content"])
      # check status is displayed
      expect(page).to have_content("Accepted")
      # check there is no comments
      expect(page).to have_no_css("div#comments")
    end
  end

  context "when the external proposal has comments" do
    let(:json_contrib) do
      {
        "reference" => "JD-PROP-2025-09-1",
        "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
        "container" => "JD-PART-2025-09-1",
        "locale" => "en",
        "title" => "Quia sapiente.",
        "content" => "Debitis repellat provident. Earum dolorem eaque. Aut quia officiis.",
        "authors" => [
          "Aldo Davis"
        ],
        "parent" => nil,
        "children" => [
          {
            "reference" => "JD-PROP-2025-09-1-249",
            "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
            "container" => "JD-PART-2025-09-1",
            "locale" => "en",
            "title" => nil,
            "content" => "Cumque hic quia veniam et dolores aliquam commodi laudantium omnis expedita enim natus et beatae quidem dolores architecto repudiandae rem a corporis impedit rerum fugit neque eos dicta deserunt consequatur numquam magnam voluptate inventore omnis aut porro nemo voluptas sit quia saepe aut provident accusantium voluptatem illum nam quaerat molestiae.",
            "authors" => "Kautzer-Mayer",
            "parent" => "JD-PROP-2025-09-1",
            "children" => [
              "JD-PROP-2025-09-1-250"
            ],
            "metadata" => {
              "depth" => 0
            },
            "created_at" => "2025-09-11T10:20:23.609Z",
            "updated_at" => "2025-09-11T10:20:23.609Z",
            "deleted_at" => nil
          },
          {
            "reference" => "JD-PROP-2025-09-1-250",
            "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
            "container" => "JD-PART-2025-09-1",
            "locale" => "en",
            "title" => nil,
            "content" => "Voluptatem illum sit eius eligendi omnis dolore qui alias et occaecati eos ipsum blanditiis unde fugit minus est quia excepturi eos ut nam iste molestias cupiditate et vel repellat quidem qui non est porro commodi quia mollitia reiciendis odit rem voluptas tempora autem et sequi quos provident accusantium fugiat accusamus.",
            "authors" => "Aldo Davis",
            "parent" => "JD-PROP-2025-09-1-249",
            "children" => nil,
            "metadata" => {
              "depth" => 1
            },
            "created_at" => "2025-09-11T10:20:24.655Z",
            "updated_at" => "2025-09-11T10:20:24.655Z",
            "deleted_at" => nil
          }
        ],
        "metadata" => {
          "state" => {
            "withdrawn" => false,
            "emendation" => false,
            "state" => nil
          }
        },
        "created_at" => "2025-09-11T10:20:21.222Z",
        "updated_at" => "2025-09-11T10:21:56.604Z",
        "deleted_at" => nil
      }
    end

    it "displays external proposal with its comments" do
      expect(page).to have_css("h1", text: "Quia sapiente.")
      expect(page).to have_css("p.author_name", text: "Aldo Davis")
      expect(page).to have_css("div.rich-text-display", text: json_contrib["content"])
      # check comments are displayed
      expect(page).to have_css("div#comments")
      expect(page).to have_css("span.comments-count", text: "2 comments")
      within "div.comment-thread" do
        expect(page).to have_css("div#comment_JD-PROP-2025-09-1-249")
        expect(page).to have_css("div#accordion-JD-PROP-2025-09-1-249")
      end
    end
  end

  private

  def decidim_proposals
    Decidim::EngineRouter.main_proxy(component)
  end

  def visit_external_proposal
    visit decidim_proposals.external_proposal_proposals_path("JD-PROP-2025-09-1")
  end
end

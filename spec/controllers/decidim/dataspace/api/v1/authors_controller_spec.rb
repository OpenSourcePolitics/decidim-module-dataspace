# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::AuthorsController do
  routes { Decidim::Dataspace::Engine.routes }

  describe "index" do
    context "when dataspace is disabled" do
      let!(:component) { create(:proposal_component) }

      before do
        request.env["decidim.current_organization"] = component.organization
        get :index
      end

      it "returns a forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when dataspace is enabled" do
      let!(:component) { create(:proposal_component) }

      before do
        request.env["decidim.current_organization"] = component.organization
        component.organization.enable_dataspace = true
        component.organization.save!
      end

      context "and there are proposals and authors" do
        let!(:proposal) { create(:proposal, :participant_author, component:) }
        let!(:proposal_two) { create(:proposal, :official_meeting, component:) }
        let!(:proposal_three) { create(:proposal, :official, component:) }

        it "is a success, and it returns json with 3 authors" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("application/json")
          expect { response.parsed_body }.not_to raise_error
          # we have 3 different authors
          expect(response.parsed_body.size).to eq(3)
        end
      end

      context "and there are no proposals and so no authors" do
        it "is a not_found and returns json without authors" do
          get :index
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to include("application/json")
          expect(response.parsed_body).to eq({ "error" => "Authors not found" })
        end
      end
    end
  end

  describe "show" do
    context "when dataspace is disabled" do
      let(:component) { create(:proposal_component) }
      let!(:proposal) { create(:proposal, :participant_author, component:) }

      before do
        request.env["decidim.current_organization"] = component.organization
        get :show, params: { reference: proposal.authors.first.name }
      end

      it "returns a forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when dataspace is enabled" do
      let(:component) { create(:proposal_component) }
      let!(:proposal) { create(:proposal, :participant_author, component:) }

      before do
        request.env["decidim.current_organization"] = component.organization
        component.organization.enable_dataspace = true
        component.organization.save!
      end

      context "and author exists" do
        it "is a success and returns json" do
          get :show, params: { reference: proposal.authors.first.name }
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("application/json")
          expect { response.parsed_body }.not_to raise_error
        end

        context "and author is a user" do
          it "returns the author" do
            author = proposal.authors.first
            get :show, params: { reference: author.name }
            expect(response.parsed_body).to eq({ "reference" => author.name,
                                                 "name" => author.name,
                                                 "source" => author.personal_url })
          end
        end

        context "and author is a official" do
          let!(:proposal) { create(:proposal, :official, component:) }

          it "returns the author" do
            author = proposal.authors.first
            get :show, params: { reference: author.reference_prefix }
            expect(response.parsed_body).to eq({ "reference" => author.reference_prefix,
                                                 "name" => author.name["en"],
                                                 "source" => author.official_url })
          end
        end

        context "and author is a meeting" do
          let!(:proposal) { create(:proposal, :official_meeting, component:) }

          it "returns the author" do
            author = proposal.authors.first
            get :show, params: { reference: author.reference }
            expect(response.parsed_body).to eq({ "reference" => author.reference,
                                                 "name" => author.title["en"],
                                                 "source" => Decidim::ResourceLocatorPresenter.new(author).url })
          end
        end
      end

      context "when author does not exist" do
        it "is a not_found and returns json message" do
          get :show, params: { reference: "XXX" }
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to include("application/json")
          expect(response.parsed_body).to eq({ "error" => "Author not found" })
        end
      end
    end
  end
end

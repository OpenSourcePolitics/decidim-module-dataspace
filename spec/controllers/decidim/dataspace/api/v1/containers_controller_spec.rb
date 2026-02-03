# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::ContainersController do
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

      context "and there are proposals and containers" do
        let!(:proposal) { create(:proposal, component:) }
        let!(:proposal_two) { create(:proposal, component:) }

        before do
          get :index
        end

        it "is a success and returns json" do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("application/json")
          expect { response.parsed_body }.not_to raise_error
        end

        it "returns all containers" do
          # proposals are created from participatory_process
          expect(response.parsed_body.size).to eq(1)
        end
      end

      context "and there are no proposals and so no containers" do
        it "is a not_found and returns json without authors" do
          get :index
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to include("application/json")
          expect(response.parsed_body).to eq({ "error" => "Containers not found" })
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
      let!(:component) { create(:proposal_component) }

      before do
        request.env["decidim.current_organization"] = component.organization
        component.organization.enable_dataspace = true
        component.organization.save!
      end

      context "and container exists" do
        let(:proposal) { create(:proposal, component:) }
        let!(:container) { proposal.component.participatory_space_type.constantize.find(proposal.component.participatory_space_id) }

        before do
          get :show, params: { reference: container.reference }
        end

        it "is a success and returns json" do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("application/json")
          expect { response.parsed_body }.not_to raise_error
        end

        it "returns the container" do
          expect(response.parsed_body["reference"]).to eq(container.reference)
          expect(response.parsed_body["source"]).to eq(Decidim::ResourceLocatorPresenter.new(container).url)
          expect(response.parsed_body["name"]).to eq(container.title["en"])
          expect(response.parsed_body["description"]).to eq(container.description["en"])
        end
      end

      context "when container does not exist" do
        it "is a not_found and returns json message" do
          get :show, params: { reference: "XXX" }
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to include("application/json")
          expect(response.parsed_body).to eq({ "error" => "Container not found" })
        end
      end
    end
  end
end

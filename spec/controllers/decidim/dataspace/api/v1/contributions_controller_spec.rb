# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::ContributionsController do
  routes { Decidim::Dataspace::Engine.routes }

  describe "index" do
    context "when there are contributions" do
      let(:component) { create(:proposal_component) }
      let!(:proposal) { create(:proposal, component:) }
      let!(:proposal_two) { create(:proposal, component:) }
      let!(:proposal_three) { create(:proposal, component:) }

      it "is a success and returns json with contributions" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
        expect(response.parsed_body.size).to eq(3)
      end
    end

    context "when there are no contributions" do
      it "is a not_found and returns json without authors" do
        get :index
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to include("application/json")
        expect(response.parsed_body).to eq({ "error" => "Contributions not found" })
      end
    end
  end

  describe "show" do
    let(:component) { create(:proposal_component) }
    let!(:proposal) { create(:proposal, component:) }

    context "when contribution exists" do
      before do
        get :show, params: { reference: proposal.reference }
      end

      it "is a success and returns json" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
      end

      it "returns the contribution" do
        expect(response.parsed_body["reference"]).to eq(proposal.reference)
        expect(response.parsed_body["source"]).to eq(Decidim::ResourceLocatorPresenter.new(proposal).url)
        expect(response.parsed_body["container"]).to eq(proposal.component.participatory_space_type.constantize.find(proposal.component.participatory_space_id).reference)
        expect(response.parsed_body["title"]).to eq(proposal.title["en"])
        expect(response.parsed_body["content"]).to eq(proposal.body["en"])
      end
    end

    context "when contribution does not exist" do
      it "is a not_found and returns json message" do
        get :show, params: { reference: "XXX" }
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to include("application/json")
        expect(response.parsed_body).to eq({ "error" => "Contribution not found" })
      end
    end
  end
end

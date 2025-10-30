# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::DataController do
  routes { Decidim::Dataspace::Engine.routes }

  let(:component) { create(:proposal_component) }
  let!(:proposal) { create(:proposal, :participant_author, component:) }
  let!(:proposal_two) { create(:proposal, :official_meeting, component:) }
  let!(:proposal_three) { create(:proposal, :official, component:) }

  describe "index" do
    before do
      get :index
    end

    it "is successful and returns json" do
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/json")
      expect { response.parsed_body }.not_to raise_error
    end

    it "returns all data" do
      expect(response.parsed_body["contributions"].size).to eq(3)
      expect(response.parsed_body["authors"].size).to eq(3)
      expect(response.parsed_body["containers"].size).to eq(1)
    end
  end
end

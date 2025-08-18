# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::DataController do
  routes { Decidim::Dataspace::Engine.routes }

  let!(:author) { create(:author_one) }
  let(:container) { create(:container) }
  let!(:contribution) { create(:contribution, container:) }

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
      expect(response.parsed_body).to eq({ "containers" => [{ "reference" => container.reference,
                                                              "source" => container.source,
                                                              "name" => container.name,
                                                              "description" => container.description,
                                                              "metadata" => container.metadata,
                                                              "created_at" => container.created_at.as_json,
                                                              "updated_at" => container.updated_at.as_json,
                                                              "deleted_at" => container.deleted_at }],
                                           "contributions" => [{ "reference" => contribution.reference,
                                                                 "source" => contribution.source,
                                                                 "container" => contribution.container.reference,
                                                                 "locale" => contribution.locale,
                                                                 "title" => contribution.title,
                                                                 "content" => contribution.content,
                                                                 "authors" => contribution.authors&.map(&:reference),
                                                                 "metadata" => contribution.metadata,
                                                                 "parent" => contribution.parent&.reference,
                                                                 "created_at" => contribution.created_at.as_json,
                                                                 "updated_at" => contribution.updated_at.as_json,
                                                                 "deleted_at" => contribution.deleted_at }],
                                           "authors" => [{ "reference" => author.reference,
                                                           "name" => author.name,
                                                           "source" => author.source }] })
    end
  end
end

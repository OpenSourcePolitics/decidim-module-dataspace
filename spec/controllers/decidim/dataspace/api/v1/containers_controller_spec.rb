# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::ContainersController do
  routes { Decidim::Dataspace::Engine.routes }

  describe "index" do
    context "when there are containers" do
      let!(:container) { create(:container) }
      let!(:container_two) { create(:container, reference: "B02", source: "https://example-container.com/") }

      before do
        get :index
      end

      it "is a success and returns json" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
      end

      it "returns all containers" do
        expect(response.parsed_body).to eq({ "containers" => [{ "reference" => container.reference,
                                                                "source" => container.source,
                                                                "name" => container.name,
                                                                "description" => container.description,
                                                                "metadata" => container.metadata,
                                                                "created_at" => container.created_at.as_json,
                                                                "updated_at" => container.updated_at.as_json,
                                                                "deleted_at" => container.deleted_at }, # deleted_at is nil
                                                              { "reference" => container_two.reference,
                                                                "source" => container_two.source,
                                                                "name" => container_two.name,
                                                                "description" => container_two.description,
                                                                "metadata" => container_two.metadata,
                                                                "created_at" => container_two.created_at.as_json,
                                                                "updated_at" => container_two.updated_at.as_json,
                                                                "deleted_at" => container_two.deleted_at }] })
      end
    end

    context "when there are no containers" do
      it "is a success and returns json without containers" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect(response.parsed_body["containers"].size).to eq(0)
      end
    end
  end

  describe "show" do
    context "when container exists" do
      let!(:container) { create(:container) }

      before do
        get :show, params: { reference: "B01" }
      end

      it "is a success and returns json" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
      end

      it "returns the container" do
        expect(response.parsed_body).to eq({
                                             "reference" => container.reference,
                                             "source" => container.source,
                                             "name" => container.name,
                                             "description" => container.description,
                                             "metadata" => container.metadata,
                                             "created_at" => container.created_at.as_json,
                                             "updated_at" => container.updated_at.as_json,
                                             "deleted_at" => container.deleted_at
                                           })
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

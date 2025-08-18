# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::ContributionsController do
  routes { Decidim::Dataspace::Engine.routes }

  describe "index" do
    context "when there are contributions" do
      let(:contribution) { create(:contribution, :with_two_authors) }
      let!(:parent_contrib) { create(:parent_contrib, container: contribution.container) }

      it "is a success and returns json with contributions" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
        expect(response.parsed_body["contributions"].size).to eq(2)
      end
    end

    context "when there are no contributions" do
      it "is a success and returns json with empty contributions" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
        expect(response.parsed_body["contributions"].size).to eq(0)
      end
    end
  end

  describe "show" do
    let(:contribution) { create(:contribution, :with_two_authors) }
    let!(:parent_contrib) { create(:parent_contrib, container: contribution.container) }

    context "when contribution exists" do
      before do
        # rubocop:disable Rails/SkipsModelValidations
        contribution.update_column("parent_id", parent_contrib.id)
        # rubocop:enable Rails/SkipsModelValidations
        get :show, params: { reference: "C01" }
      end

      it "is a success and returns json" do
        get :show, params: { reference: "C01" }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
      end

      it "returns the contribution" do
        expect(response.parsed_body).to eq({
                                             "reference" => contribution.reference,
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
                                             "deleted_at" => contribution.deleted_at
                                           })
        expect(response.parsed_body["authors"]).to eq(%w(A01 A02))
        expect(response.parsed_body["parent"]).to eq("C02")
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

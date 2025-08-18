# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::AuthorsController do
  routes { Decidim::Dataspace::Engine.routes }

  describe "index" do
    context "when there are authors" do
      let!(:author) { create(:author_one) }
      let!(:author_two) { create(:author_two) }

      before do
        get :index
      end

      it "is a success and returns json" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
      end

      it "returns all authors" do
        expect(response.parsed_body).to eq({ "authors" => [{ "reference" => author.reference,
                                                             "name" => author.name,
                                                             "source" => author.source },
                                                           { "reference" => author_two.reference,
                                                             "name" => author_two.name,
                                                             "source" => author_two.source }] })
      end
    end

    context "when there are no authors" do
      it "is a success and returns json without authors" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect(response.parsed_body["authors"].size).to eq(0)
      end
    end
  end

  describe "show" do
    context "when author exists" do
      let!(:author) { create(:author_one) }

      it "is a success and returns json" do
        get :show, params: { reference: "A01" }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
      end

      it "returns the author" do
        # "A01" is the reference of author
        get :show, params: { reference: "A01" }
        expect(response.parsed_body).to eq({ "reference" => author.reference,
                                             "name" => author.name,
                                             "source" => author.source })
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

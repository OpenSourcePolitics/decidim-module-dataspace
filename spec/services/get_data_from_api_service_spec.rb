# frozen_string_literal: true

require "spec_helper"
require "net/http"
require "uri"

RSpec.describe GetDataFromApi, type: :model do
  context "when testing contributions" do
    let(:url) { "http://localhost:3000" }

    context "when testing list" do
      let(:uri) { URI("http://localhost:3000/api/v1/data/contributions?preferred_locale=en") }
      let(:contrib_one) do
        { "reference" => "JD-PROP-2025-09-1",
          "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
          "container" => "JD-PART-2025-09-1",
          "locale" => "en",
          "title" => "Test one",
          "content" => "Debitis repellat provident",
          "authors" => ["JD-MEET-2025-09-6"],
          "created_at" => "2025-09-11T10:20:21.222Z",
          "updated_at" => "2025-09-11T10:21:56.604Z",
          "deleted_at" => nil }
      end
      let(:contrib_two) do
        { "reference" => "JD-PROP-2025-09-20",
          "source" => "http://localhost:3000/assemblies/smile-trivial/f/25/proposals/20",
          "container" => "JD-ASSE-2025-09-1",
          "locale" => "en",
          "title" => "Test two",
          "content" => "Non et vel",
          "authors" => ["JD-MEET-2025-09-23"],
          "created_at" => "2025-09-11T10:43:23.743Z",
          "updated_at" => "2025-09-11T10:43:27.147Z",
          "deleted_at" => nil }
      end

      let(:json) { [contrib_one, contrib_two].to_json }

      before do
        allow(Net::HTTP).to receive(:get).with(uri).and_return(json)
      end

      it "returns json containing a list of contributions" do
        response = GetDataFromApi.contributions(url, "en")
        expect(response.class).to eq Array
        expect(response.size).to eq(2)
        expect(response[0]["title"]).to eq("Test one")
      end
    end

    context "when testing show" do
      let(:uri) { URI("http://localhost:3000/api/v1/data/contributions/JD-PROP-2025-09-1?preferred_locale=en") }
      let(:json) do
        { "reference" => "JD-PROP-2025-09-1",
          "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
          "container" => "JD-PART-2025-09-1",
          "locale" => "en",
          "title" => "Test one",
          "content" => "Debitis repellat provident",
          "authors" => ["JD-MEET-2025-09-6"],
          "created_at" => "2025-09-11T10:20:21.222Z",
          "updated_at" => "2025-09-11T10:21:56.604Z",
          "deleted_at" => nil }.to_json
      end

      let(:ref) { "JD-PROP-2025-09-1" }

      before do
        allow(Net::HTTP).to receive(:get).with(uri).and_return(json)
      end

      it "returns json containing one contribution" do
        response = GetDataFromApi.contribution(url, ref, "en")
        expect(response.class).to eq Hash
        expect(response["reference"]).to eq("JD-PROP-2025-09-1")
        expect(response["title"]).to eq("Test one")
      end
    end
  end
end

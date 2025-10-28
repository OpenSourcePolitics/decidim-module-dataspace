# frozen_string_literal: true

require "spec_helper"
require "net/http"
require "uri"

RSpec.describe "GetDataFromApi" do
  context "when testing contributions" do
    let(:url) { "http://example.com" }

    context "when testing list" do
      let(:uri) { URI("http://example.com/api/v1/data/contributions?preferred_locale=en") }
      let(:contrib_one) do
        { "reference" => "JD-PROP-2025-09-1",
          "source" => "http://example.com/processes/satisfaction-hope/f/7/proposals/1",
          "container" => "JD-PART-2025-09-1",
          "locale" => "en",
          "title" => "Test one",
          "content" => "Debitis repellat provident",
          "authors" => ["JD-MEET-2025-09-6"],
          "parent" => nil,
          "children" => [],
          "created_at" => "2025-09-11T10:20:21.222Z",
          "updated_at" => "2025-09-11T10:21:56.604Z",
          "deleted_at" => nil }
      end
      let(:contrib_two) do
        { "reference" => "JD-PROP-2025-09-20",
          "source" => "http://example.com/assemblies/smile-trivial/f/25/proposals/20",
          "container" => "JD-ASSE-2025-09-1",
          "locale" => "en",
          "title" => "Test two",
          "content" => "Non et vel",
          "authors" => ["JD-MEET-2025-09-23"],
          "parent" => nil,
          "children" => [],
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

    context "when testing show with with_comments false" do
      let(:uri) { URI("http://example.com/api/v1/data/contributions/JD-PROP-2025-09-1?preferred_locale=en&with_comments=false") }
      let(:json) do
        { "reference" => "JD-PROP-2025-09-1",
          "source" => "http://example.com/processes/satisfaction-hope/f/7/proposals/1",
          "container" => "JD-PART-2025-09-1",
          "locale" => "en",
          "title" => "Test one",
          "content" => "Debitis repellat provident",
          "authors" => ["JD-MEET-2025-09-6"],
          "parent" => nil,
          "children" => %w(JD-PART-2025-09-1-249 JD-PART-2025-09-1-250),
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
        expect(response["children"]).to eq(["JD-PART-2025-09-1-249", "JD-PART-2025-09-1-250"])
      end
    end

    context "when testing show with with_comments true" do
      let(:uri) { URI("http://example.com/api/v1/data/contributions/JD-PROP-2025-09-1?preferred_locale=en&with_comments=true") }
      let(:json) do
        { "reference" => "JD-PROP-2025-09-1",
          "source" => "http://example.com/processes/satisfaction-hope/f/7/proposals/1",
          "container" => "JD-PART-2025-09-1",
          "locale" => "en",
          "title" => "Test one",
          "content" => "Debitis repellat provident",
          "authors" => ["JD-MEET-2025-09-6"],
          "parent" => nil,
          "children" => [
            {
              "reference" => "JD-PROP-2025-09-1-249",
              "source" => "http://example.com/processes/satisfaction-hope/f/7/proposals/1",
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
              "source" => "http://example.com/processes/satisfaction-hope/f/7/proposals/1",
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
          "created_at" => "2025-09-11T10:20:21.222Z",
          "updated_at" => "2025-09-11T10:21:56.604Z",
          "deleted_at" => nil }.to_json
      end

      let(:ref) { "JD-PROP-2025-09-1" }

      before do
        allow(Net::HTTP).to receive(:get).with(uri).and_return(json)
      end

      it "returns json containing one contribution and its detailed comments" do
        response = GetDataFromApi.contribution(url, ref, "en", "true")
        expect(response.class).to eq Hash
        expect(response["reference"]).to eq("JD-PROP-2025-09-1")
        expect(response["title"]).to eq("Test one")
        expect(response["children"].class).to eq(Array)
        expect(response["children"].first.class).to eq(Hash)
        expect(response["children"].first["reference"]).to eq("JD-PROP-2025-09-1-249")
      end
    end
  end
end

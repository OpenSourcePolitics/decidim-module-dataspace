# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dataspace::Api::V1::ContributionsController do
  routes { Decidim::Dataspace::Engine.routes }

  describe "index" do
    context "when there are contributions with comments" do
      let(:component) { create(:proposal_component) }
      let!(:proposal) { create(:proposal, component:) }
      let!(:comment_one) { create(:comment, commentable: proposal) }
      let!(:comment_two) { create(:comment, commentable: proposal) }
      let!(:proposal_two) { create(:proposal, component:) }
      let!(:proposal_three) { create(:proposal, component:) }

      context "and with_comments is false" do
        it "is a success and returns json with only proposals as contributions" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("application/json")
          expect { response.parsed_body }.not_to raise_error
          # only proposals are rendered
          expect(response.parsed_body.size).to eq(3)
        end
      end

      context "and with_comments is true" do
        it "is a success and returns json with proposals and comments as contributions" do
          get :index, params: { with_comments: "true" }
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("application/json")
          expect { response.parsed_body }.not_to raise_error
          # proposals + comments are rendered
          expect(response.parsed_body.size).to eq(5)
        end
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

    context "when there is a container param" do
      let(:component_two) { create(:proposal_component) }
      let!(:proposal_four) { create(:proposal, :participant_author, component: component_two) }

      before do
        get :index, params: { container: component_two.participatory_space.reference }
      end

      it "is a success and returns json with filtered proposals as contributions" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        expect { response.parsed_body }.not_to raise_error
        # only proposal_four is rendered
        expect(response.parsed_body.size).to eq(1)
        expect(response.parsed_body.first["reference"]).to eq(proposal_four.reference)
      end
    end
  end

  describe "show" do
    let(:component) { create(:proposal_component) }
    let!(:proposal) { create(:proposal, component:) }
    let!(:comment_one) { create(:comment, commentable: proposal) }
    let!(:comment_two) { create(:comment, commentable: proposal) }

    context "when contribution exists" do
      context "and with comments is false" do
        before do
          get :show, params: { reference: proposal.reference }
        end

        it "is a success and returns json" do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("application/json")
          expect { response.parsed_body }.not_to raise_error
        end

        it "returns the contribution with no detailed comments" do
          expect(response.parsed_body["reference"]).to eq(proposal.reference)
          expect(response.parsed_body["source"]).to eq(Decidim::ResourceLocatorPresenter.new(proposal).url)
          expect(response.parsed_body["container"]).to eq(proposal.component.participatory_space_type.constantize.find(proposal.component.participatory_space_id).reference)
          expect(response.parsed_body["title"]).to eq(proposal.title["en"])
          expect(response.parsed_body["content"]).to eq(proposal.body["en"])
          # 2 comments without details
          expect(response.parsed_body["children"].size).to eq(2)
          expect(response.parsed_body["children"].first.class).to eq(String)
          expect(response.parsed_body["children"].first).to eq("#{proposal["reference"]}-#{comment_one.id}")
        end
      end

      context "and with comments is true" do
        before do
          get :show, params: { reference: proposal.reference, with_comments: "true" }
        end

        it "is a success and returns json" do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("application/json")
          expect { response.parsed_body }.not_to raise_error
        end

        it "returns the contribution with detailed comments" do
          expect(response.parsed_body["reference"]).to eq(proposal.reference)
          expect(response.parsed_body["source"]).to eq(Decidim::ResourceLocatorPresenter.new(proposal).url)
          expect(response.parsed_body["container"]).to eq(proposal.component.participatory_space_type.constantize.find(proposal.component.participatory_space_id).reference)
          expect(response.parsed_body["title"]).to eq(proposal.title["en"])
          expect(response.parsed_body["content"]).to eq(proposal.body["en"])
          # 2 comments with details
          expect(response.parsed_body["children"].size).to eq(2)
          expect(response.parsed_body["children"].first.class).to eq(Hash)
          expect(response.parsed_body["children"].first["reference"]).to eq("#{proposal["reference"]}-#{comment_one.id}")
          expect(response.parsed_body["children"].first["content"]).to eq(comment_one.body["en"])
        end
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

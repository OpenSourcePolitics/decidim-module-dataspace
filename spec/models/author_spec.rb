# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe Author do
      subject { author }

      context "when valid" do
        context "when build" do
          let(:author) { build(:author_one) }

          it { is_expected.to be_valid }
        end

        context "when create" do
          let(:author) { create(:author_two) }

          it "is expected to give the reference and source" do
            expect(author.reference).to eq("A02")
            expect(author.source).to eq("https://example.com/account/johnsmith")
          end
        end
      end

      context "when invalid" do
        context "without reference" do
          let(:author) { build(:author_one, reference: "") }

          it { is_expected.not_to be_valid }
        end

        context "without source" do
          let(:author) { build(:author_one, source: "") }

          it { is_expected.not_to be_valid }
        end
      end

      context "when deleting author" do
        let!(:author) { create(:author_one) }

        it "destroys associated interoperable" do
          expect { author.destroy }.to change(Decidim::Dataspace::Interoperable, :count).by(-1)
        end
      end

      context "when using from_proposals method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, :participant_author, component:) }
        let!(:proposal_two) { create(:proposal, :official_meeting, component:) }
        let!(:proposal_three) { create(:proposal, :official, component:) }

        it "returns an array with 3 hash elements" do
          expect(Author.from_proposals("en").class).to eq(Array)
          expect(Author.from_proposals("en").size).to eq(3)
          expect(Author.from_proposals("en").first.class).to eq(Hash)
        end
      end

      context "when using proposal_author method" do
        context "and user as author" do
          let(:component) { create(:proposal_component) }
          let(:proposal) { create(:proposal, :participant_author, component:) }
          let!(:author) { proposal.authors.first }

          it "returns a hash with author name as reference" do
            # for user author, the reference is the name
            expect(Author.proposal_author(author.name, "en").class).to eq(Hash)
            expect(Author.proposal_author(author.name, "en").size).to eq(3)
            expect(Author.proposal_author(author.name, "en")[:reference]).to eq(proposal.authors.first.name)
          end
        end

        context "and official as author" do
          let(:component) { create(:proposal_component) }
          let(:proposal) { create(:proposal, :official, component:) }
          let!(:author) { proposal.authors.first }

          it "returns a hash with organization reference_prefix as reference" do
            # for official author, the reference is the reference_prefix
            expect(Author.proposal_author(author.reference_prefix, "en").class).to eq(Hash)
            expect(Author.proposal_author(author.reference_prefix, "en").size).to eq(3)
            expect(Author.proposal_author(author.reference_prefix, "en")[:reference]).to eq(proposal.authors.first.reference_prefix)
          end
        end

        context "and official meeting as author" do
          let(:component) { create(:proposal_component) }
          let(:proposal) { create(:proposal, :official_meeting, component:) }
          let!(:author) { proposal.authors.first }

          it "returns a hash with organization reference_prefix as reference" do
            # for official_meeting author, the reference is the reference
            expect(Author.proposal_author(author.reference, "en").class).to eq(Hash)
            expect(Author.proposal_author(author.reference, "en").size).to eq(3)
            expect(Author.proposal_author(author.reference, "en")[:reference]).to eq(proposal.authors.first.reference)
          end
        end
      end
    end
  end
end

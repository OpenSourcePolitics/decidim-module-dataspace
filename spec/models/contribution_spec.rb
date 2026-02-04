# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe Contribution do
      context "when using self.from_proposals method with 3 proposals and 2 comments" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, component:) }
        let!(:comment_one) { create(:comment, commentable: proposal) }
        let!(:comment_two) { create(:comment, commentable: proposal) }
        let!(:proposal_two) { create(:proposal, component:) }
        let!(:proposal_three) { create(:proposal, component:) }

        context "and with_comments is false" do
          it "returns an array with 3 hash proposals elements" do
            method_call = Contribution.from_proposals("en")
            expect(method_call.class).to eq(Array)
            expect(method_call.size).to eq(3)
            expect(method_call.first.class).to eq(Hash)
            expect(method_call.first[:children].size).to eq(2)
          end
        end

        context "and with_comments is true" do
          it "returns an array with 5 proposals+comments hash elements" do
            method_call = Contribution.from_proposals("en", "true")
            expect(method_call.class).to eq(Array)
            expect(method_call.size).to eq(5)
            expect(method_call.first.class).to eq(Hash)
            # first is proposal and has 2 children
            expect(method_call.first[:children].size).to eq(2)
            # second will be a comment of proposal
            expect([comment_one.reference, comment_two.reference]).to include(method_call.second[:reference])
            # last is proposal_three and has no children
            expect(method_call.last[:children]).to eq([])
          end
        end

        context "and there is a container" do
          let(:component_two) { create(:proposal_component) }
          let!(:proposal_four) { create(:proposal, :participant_author, component: component_two) }

          it "returns the proposals filtered by container" do
            method_call = Contribution.from_proposals("en", "false", component_two.participatory_space.reference)
            expect(method_call.class).to eq(Array)
            expect(method_call.size).to eq(1)
            expect(method_call.first.class).to eq(Hash)
            expect(method_call.first[:reference]).to eq(proposal_four.reference)
          end
        end
      end

      context "when using self.get_one method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, :participant_author, component:) }
        let!(:comment_one) { create(:comment, commentable: proposal) }
        let!(:comment_two) { create(:comment, commentable: proposal) }

        context "and getting a proposal" do
          context "and with_comments is false" do
            it "returns an array with 1 hash element and no detailed comments in children key" do
              method_call = Contribution.get_one(proposal.reference, "en")
              expect(method_call.class).to eq(Hash)
              # we have 13 keys in the returned hash
              expect(method_call.size).to eq(13)
              expect(method_call[:reference]).to eq(proposal.reference)
              # reference for user author is name
              expect(method_call[:authors]).to eq([proposal.authors.first.name])
              # proposal has 2 comments
              expect(method_call[:children].size).to eq(2)
              # comments are not detailed
              expect(method_call[:children].first.class).to eq(String)
              expect([comment_one.reference, comment_two.reference]).to include(method_call[:children].first)
            end
          end

          context "and with_comments is true" do
            it "returns an array with 1 hash element and detailed comments in children key" do
              method_call = Contribution.get_one(proposal.reference, "en", "true")
              expect(method_call.class).to eq(Hash)
              # we have 13 keys in the returned hash
              expect(method_call.size).to eq(13)
              expect(method_call[:reference]).to eq(proposal.reference)
              # reference for user author is name
              expect(method_call[:authors]).to eq([proposal.authors.first.name])
              # proposal has 2 comments
              expect(method_call[:children].size).to eq(2)
              # comments are detailed
              expect(method_call[:children].first.class).to eq(Hash)
              expect([comment_one.reference, comment_two.reference]).to include(method_call[:children].first[:reference])
            end
          end
        end

        context "and getting a comment" do
          it "returns an array with 1 hash element" do
            method_call = Contribution.get_one(comment_one.reference, "en")
            expect(method_call.class).to eq(Hash)
            # we have 13 keys in the returned hash
            expect(method_call.size).to eq(13)
            expect(method_call[:reference]).to eq(comment_one.reference)
            # reference for user author is name
            expect(method_call[:authors]).to eq(comment_one.author.name)
          end
        end
      end
    end
  end
end

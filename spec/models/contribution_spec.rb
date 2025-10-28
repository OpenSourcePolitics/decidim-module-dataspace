# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe Contribution do
      subject { contribution }

      context "when valid" do
        context "when build" do
          let(:contribution) { build(:contribution) }

          it { is_expected.to be_valid }

          context "without title but with content" do
            let(:contribution) { build(:contribution, title: nil) }

            it { is_expected.to be_valid }
          end

          context "without content but with title" do
            let(:contribution) { build(:contribution, content: nil) }

            it { is_expected.to be_valid }
          end
        end

        context "when create" do
          let(:contribution) { create(:contribution) }

          it "is expected to give the different values" do
            expect(contribution.title).to eq("Contribution 1")
            expect(contribution.content).to eq("Contenu de la contribution 1")
            expect(contribution.reference).to eq("C01")
            expect(contribution.source).to eq("https://example.com/contribution/1")
            expect(contribution.metadata).to eq({ "status" => "published", "type" => "proposal" })
          end
        end
      end

      context "when invalid" do
        context "without reference" do
          let(:contribution) { build(:contribution, reference: nil) }

          it { is_expected.not_to be_valid }
        end

        context "without source" do
          let(:contribution) { build(:contribution, source: nil) }

          it { is_expected.not_to be_valid }
        end

        context "without title and content" do
          let(:contribution) { build(:contribution, title: nil, content: nil) }

          it { is_expected.not_to be_valid }
        end

        context "without container" do
          let(:contribution) { build(:contribution, container_id: nil) }

          it { is_expected.not_to be_valid }
        end
      end

      context "with authors" do
        context "when 1 author" do
          let(:contribution) { create(:contribution, :contrib_one) }

          it "has 1 author" do
            expect(contribution.authors.size).to eq(1)
            expect(contribution.authors.first.name).to eq("Jane Doe")
          end
        end

        context "when 2 authors" do
          let(:contribution) { create(:contribution, :with_two_authors) }

          it "has 2 authors" do
            expect(contribution.authors.size).to eq(2)
          end
        end
      end

      context "with parent and children" do
        let(:contribution) { create(:contribution) }
        let(:parent_contrib) { create(:parent_contrib, container: contribution.container) }

        before do
          # rubocop:disable Rails/SkipsModelValidations
          contribution.update_column("parent_id", parent_contrib.id)
          # rubocop:enable Rails/SkipsModelValidations
        end

        it "has one parent" do
          expect(subject.parent).not_to be_nil
        end

        it "has one child" do
          expect(subject.parent.children.size).to eq(1)
        end
      end

      context "when deleting contribution" do
        let!(:contribution) { create(:contribution) }

        it "destroys associated interoperable" do
          expect { contribution.destroy }.to change(Decidim::Dataspace::Interoperable, :count).by(-1)
        end
      end

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
            # second will be the first comment of proposal
            expect(method_call.second[:reference]).to eq("#{method_call.first[:reference]}-#{comment_one.id}")
            # last is proposal_three and has no children
            expect(method_call.last[:children]).to eq([])
          end
        end
      end

      context "when using self.proposal method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, :participant_author, component:) }
        let!(:comment_one) { create(:comment, commentable: proposal) }
        let!(:comment_two) { create(:comment, commentable: proposal) }

        context "and with_comments is false" do
          it "returns an array with 1 hash element and no detailed comments in children key" do
            method_call = Contribution.proposal(proposal.reference, "en")
            expect(method_call.class).to eq(Hash)
            # we have 12 keys in the returned hash
            expect(method_call.size).to eq(12)
            expect(method_call[:reference]).to eq(proposal.reference)
            # reference for user author is name
            expect(method_call[:authors]).to eq([proposal.authors.first.name])
            # proposal has 2 comments
            expect(method_call[:children].size).to eq(2)
            # comments are not detailed
            expect(method_call[:children].first.class).to eq(String)
            expect(method_call[:children].first).to eq("#{method_call[:reference]}-#{comment_one.id}")
          end
        end

        context "and with_comments is true" do
          it "returns an array with 1 hash element and detailed comments in children key" do
            method_call = Contribution.proposal(proposal.reference, "en", "true")
            expect(method_call.class).to eq(Hash)
            # we have 12 keys in the returned hash
            expect(method_call.size).to eq(12)
            expect(method_call[:reference]).to eq(proposal.reference)
            # reference for user author is name
            expect(method_call[:authors]).to eq([proposal.authors.first.name])
            # proposal has 2 comments
            expect(method_call[:children].size).to eq(2)
            # comments are detailed
            expect(method_call[:children].first.class).to eq(Hash)
            expect(method_call[:children].first[:reference]).to eq("#{method_call[:reference]}-#{comment_one.id}")
          end
        end
      end
    end
  end
end

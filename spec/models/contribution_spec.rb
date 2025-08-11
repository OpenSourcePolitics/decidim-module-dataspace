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
        let(:contribution) { create(:contribution, :with_parent) }

        it "has one parent" do
          expect(subject.parent).not_to be_nil
        end

        it "has one child" do
          expect(subject.parent.children.size).to eq(1)
        end
      end
    end
  end
end

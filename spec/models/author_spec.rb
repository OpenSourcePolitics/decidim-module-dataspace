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
    end
  end
end

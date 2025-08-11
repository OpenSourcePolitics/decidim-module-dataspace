# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe Interoperable do
      subject { interoperable }

      context "when valid" do
        let(:interoperable) { build(:interoperable) }

        it { is_expected.to be_valid }
      end

      context "when invalid" do
        context "without reference" do
          let(:interoperable) { build(:interoperable, :reference_nil) }

          it { is_expected.not_to be_valid }
        end

        context "with reference not unique" do
          let(:interoperable_one) { create(:interoperable) }
          let(:interoperable) { build(:interoperable, reference: interoperable_one.reference) }

          it { is_expected.not_to be_valid }
        end

        context "without source" do
          let(:interoperable) { build(:interoperable, :source_nil) }

          it { is_expected.not_to be_valid }
        end

        context "with source not url" do
          let(:interoperable) { build(:interoperable, source: "example.org") }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end

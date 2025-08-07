# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe Author do
      subject { author }

      context "when valid" do
        let(:author) { build(:author_one) }

        it { is_expected.to be_valid }
      end

      context "when invalid" do
        context "without reference" do
          let(:author) { build(:author_one, reference: nil) }

          it { is_expected.not_to be_valid }
        end

        context "without source" do
          let(:author) { build(:author_one, source: nil) }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end

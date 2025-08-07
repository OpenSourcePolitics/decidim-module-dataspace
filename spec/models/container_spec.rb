# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe Container do
      subject { container }

      context "when valid" do
        let(:container) { build(:container) }

        it { is_expected.to be_valid }
      end

      context "when invalid" do
        context "without reference" do
          let(:container) { build(:container, reference: nil) }

          it { is_expected.not_to be_valid }
        end

        context "without source" do
          let(:container) { build(:container, source: nil) }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end

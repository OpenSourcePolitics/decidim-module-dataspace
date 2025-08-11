# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe Container do
      subject { container }

      context "when valid" do
        context "when build" do
          let(:container) { build(:container) }

          it { is_expected.to be_valid }
        end

        context "when create" do
          let(:container) { create(:container) }

          it "is expected to give the name, reference, source and metadata" do
            expect(container.name).to eq("Space 1")
            expect(container.reference).to eq("B01")
            expect(container.source).to eq("https://example.com/")
            expect(container.metadata).to eq({ "type" => "participatory_process", "visibility" => "public", "status" => "published" })
          end
        end
      end

      context "when invalid" do
        context "without reference" do
          let(:container) { build(:container, reference: nil) }

          it { is_expected.not_to be_valid }
        end

        context "without valid source url" do
          let(:container) { build(:container, source: "test.com") }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end

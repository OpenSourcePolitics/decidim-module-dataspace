# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Dataspace do
    subject { described_class }

    it "has version" do
      expect(subject.version).to eq("1.0.0")
    end

    it "has decidim version" do
      expect(subject.decidim_version).to eq("~> 0.29.3")
    end
  end
end

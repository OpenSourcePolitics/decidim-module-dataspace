# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe Container do
      context "when using from_proposals method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, component:) }
        let!(:proposal_two) { create(:proposal, component:) }
        let!(:proposal_three) { create(:proposal, component:) }

        it "returns an array with 1 hash element" do
          expect(Container.from_proposals("en").class).to eq(Array)
          expect(Container.from_proposals("en").size).to eq(1) # the 3 proposals have the same container
          expect(Container.from_proposals("en").first.class).to eq(Hash)
        end
      end

      context "when using from_params method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, component:) }
        # proposal container is a process
        let!(:container) { Decidim::ParticipatoryProcess.find(component.participatory_space_id) }

        it "returns a hash with container reference as reference" do
          expect(Container.from_params(container.reference, "en").class).to eq(Hash)
          expect(Container.from_params(container.reference, "en").size).to eq(8)
          expect(Container.from_params(container.reference, "en")[:reference]).to eq(container.reference)
        end
      end

      context "when using from_proposal method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, component:) }
        let!(:container) { Decidim::ParticipatoryProcess.find(component.participatory_space_id) }

        it "returns a hash with container reference as reference" do
          expect(Container.from_proposal(proposal, "en").class).to eq(Hash)
          expect(Container.from_proposal(proposal, "en").size).to eq(8)
          expect(Container.from_proposal(proposal, "en")[:reference]).to eq(container.reference)
        end
      end
    end
  end
end

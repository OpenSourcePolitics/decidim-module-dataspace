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

      context "with parent and children" do
        let(:container) { create(:container) }
        let(:parent_container) { create(:container, reference: "B02", container: container.container) }

        before do
          # rubocop:disable Rails/SkipsModelValidations
          container.update_column("parent_id", parent_container.id)
          # rubocop:enable Rails/SkipsModelValidations
        end

        it "has one parent" do
          expect(subject.parent).not_to be_nil
        end

        it "has one child" do
          expect(subject.parent.children.size).to eq(1)
        end
      end

      context "when deleting container" do
        let!(:container) { create(:container) }

        it "destroys associated interoperable" do
          expect { container.destroy }.to change(Decidim::Dataspace::Interoperable, :count).by(-1)
        end
      end

      context "when using from_proposals method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal,component:) }
        let!(:proposal_two) { create(:proposal, component:) }
        let!(:proposal_three) { create(:proposal, component:) }

        it "returns an array with 1 hash element" do
          expect(Container.from_proposals.class).to eq(Array)
          expect(Container.from_proposals.size).to eq(1) # the 3 proposals have the same container
          expect(Container.from_proposals.first.class).to eq(Hash)
        end
      end

      context "when using from_params method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, component:) }
        # proposal container is a process
        let!(:container) { Decidim::ParticipatoryProcess.find(component.participatory_space_id) }

        it "returns a hash with container reference as reference" do
          expect(Container.from_params(container.reference).class).to eq(Hash)
          expect(Container.from_params(container.reference).size).to eq(8)
          expect(Container.from_params(container.reference)[:reference]).to eq(container.reference)
        end
      end

      context "when using from_proposal method" do
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, component:) }
        let!(:container) { Decidim::ParticipatoryProcess.find(component.participatory_space_id) }

        it "returns a hash with container reference as reference" do
          expect(Container.from_proposal(proposal).class).to eq(Hash)
          expect(Container.from_proposal(proposal).size).to eq(8)
          expect(Container.from_proposal(proposal)[:reference]).to eq(container.reference)
        end
      end
    end
  end
end

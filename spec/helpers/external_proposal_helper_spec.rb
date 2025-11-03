# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ExternalProposalHelper do
      let!(:state) { { "withdrawn": false, "emendation": false, "state": "accepted" } }

      describe "external_state_item" do
        context "when state is blank" do
          let(:state) { {} }

          it "returns nil" do
            expect(helper.external_state_item(state)).to be_nil
          end
        end

        context "when state is not blank" do
          context "and withdrawn is true" do
            let(:state) { { "withdrawn" => true, "emendation" => false, "state" => "accepted" } }

            before do
              allow(helper).to receive(:humanize_proposal_state).and_return(I18n.t(:withdrawn, scope: "decidim.proposals.answers", default: :not_answered))
            end

            it "returns a span" do
              expect(helper.external_state_item(state)).to eq('<span class="label alert">Withdrawn</span>')
            end
          end

          context "and withdrawn is false" do
            before do
              allow(helper).to receive(:humanize_proposal_state).and_return(I18n.t(state["state"], scope: "decidim.proposals.answers", default: :not_answered))
            end

            context "and emendation is true" do
              let(:state) { { "withdrawn" => false, "emendation" => true, "state" => "accepted" } }

              it "returns a span" do
                expect(helper.external_state_item(state)).to eq('<span class="label success">Accepted</span>')
              end
            end

            context "and emendation is false" do
              context "and state is accepted" do
                let(:state) { { "withdrawn" => false, "emendation" => false, "state" => "accepted" } }

                it "returns a span" do
                  expect(helper.external_state_item(state)).to eq('<span class="label" style="background-color: #E3FCE9; color: #15602C; border-color: #15602C;">Accepted</span>')
                end
              end

              context "and state is rejected" do
                let(:state) { { "withdrawn" => false, "emendation" => false, "state" => "rejected" } }

                it "returns a span" do
                  expect(helper.external_state_item(state)).to eq('<span class="label" style="background-color: #FFEBE9; color: #D1242F; border-color: #D1242F;">Rejected</span>')
                end
              end

              context "and state is evaluating" do
                let(:state) { { "withdrawn" => false, "emendation" => false, "state" => "evaluating" } }

                it "returns a span" do
                  expect(helper.external_state_item(state)).to eq('<span class="label" style="background-color: #FFF1E5; color: #BC4C00; border-color: #BC4C00;">Evaluating</span>')
                end
              end
            end
          end
        end
      end

      describe "display_host" do
        let(:url) { "http://localhost:3000" }

        it "returns the host" do
          expect(helper.display_host(url)).to eq("localhost")
        end
      end
    end
  end
end

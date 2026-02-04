# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe ContributionPresenter do
      let(:component) { create(:proposal_component) }
      let(:proposal) { create(:proposal, component:) }
      let!(:comment_one) { create(:comment, commentable: proposal) }
      let!(:comment_two) { create(:comment, commentable: proposal) }
      let!(:locale) { "en" }

      describe "comment method" do
        let(:presenter) { ContributionPresenter.new(comment_one) }

        it "returns a hash with comment informations" do
          method_call = presenter.comment(proposal, component, locale)
          expect(method_call.class).to eq(Hash)
          expect(method_call.size).to eq(13)
          expect(method_call[:reference]).to eq(comment_one.reference)
          expect(method_call[:content]).to eq(translated_attribute(comment_one.body))
          expect(method_call[:parent]).to eq(proposal.reference)
        end
      end

      describe "proposal_with_comments method" do
        let(:presenter) { ContributionPresenter.new(proposal) }

        it "returns a hash with proposal informations and detailed comments" do
          method_call = presenter.proposal_with_comments(component, locale)
          expect(method_call.class).to eq(Hash)
          expect(method_call.size).to eq(13)
          expect(method_call[:reference]).to eq(proposal.reference)
          expect(method_call[:title]).to eq(translated_attribute(proposal.title))
          expect(method_call[:children].map { |hash| hash[:reference] }).to include(comment_one.reference)
          expect(method_call[:children].map { |hash| hash[:reference] }).to include(comment_two.reference)
        end
      end

      describe "proposal_without_comment method" do
        let(:presenter) { ContributionPresenter.new(proposal) }

        it "returns a hash with proposal informations and no detailed comments" do
          method_call = presenter.proposal_without_comment(component, locale)
          expect(method_call.class).to eq(Hash)
          expect(method_call.size).to eq(13)
          expect(method_call[:reference]).to eq(proposal.reference)
          expect(method_call[:title]).to eq(translated_attribute(proposal.title))
          expect([comment_one.reference, comment_two.reference]).to include(method_call[:children].first)
          expect([comment_one.reference, comment_two.reference]).to include(method_call[:children].last)
        end
      end
    end
  end
end

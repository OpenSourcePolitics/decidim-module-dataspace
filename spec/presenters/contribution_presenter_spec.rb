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
          expect(method_call[:children]).to include({:authors => comment_one.author.name,
                                                     :children => Decidim::Dataspace::Contribution.children(comment_one),
                                                     :container => component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
                                                     :content => comment_one.body[locale] || comment_one.body["en"],
                                                     :created_at => comment_one.created_at,
                                                     :deleted_at => comment_one.deleted_at,
                                                     :locale => locale,
                                                     :metadata => { depth: comment_one.depth, alignment: comment_one.alignment },
                                                     :parent => Decidim::Dataspace::Contribution.parent(comment_one, proposal),
                                                     :reference => comment_one.reference,
                                                     :source => Decidim::ResourceLocatorPresenter.new(proposal).url,
                                                     :title => nil,
                                                     :updated_at => comment_one.updated_at
                                                    })
          expect(method_call[:children]).to include({:authors => comment_two.author.name,
                                                     :children => Decidim::Dataspace::Contribution.children(comment_two),
                                                     :container => component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
                                                     :content => comment_two.body[locale] || comment_two.body["en"],
                                                     :created_at => comment_two.created_at,
                                                     :deleted_at => comment_two.deleted_at,
                                                     :locale => locale,
                                                     :metadata => { depth: comment_two.depth, alignment: comment_two.alignment },
                                                     :parent => Decidim::Dataspace::Contribution.parent(comment_two, proposal),
                                                     :reference => comment_two.reference,
                                                     :source => Decidim::ResourceLocatorPresenter.new(proposal).url,
                                                     :title => nil,
                                                     :updated_at => comment_two.updated_at
                                                    })
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
          expect(method_call[:children]).to eq([comment_one.reference, comment_two.reference])
        end
      end
    end
  end
end

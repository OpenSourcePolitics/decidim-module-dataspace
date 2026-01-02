# frozen_string_literal: true

module Decidim
  module Dataspace
    class Author < Decidim::Dataspace::Interoperable
      self.table_name = "dataspace_authors"

      belongs_to :interoperable, inverse_of: :container, class_name: "Decidim::Dataspace::Interoperable", dependent: :destroy
      # rubocop:disable Rails/HasAndBelongsToMany
      has_and_belongs_to_many :contributions, join_table: :decidim_contributions_authors
      # rubocop:enable Rails/HasAndBelongsToMany

      delegate :reference, :source, :created_at, :updated_at, :deleted_at, to: :interoperable

      def self.from_proposals(preferred_locale)
        proposals = Decidim::Proposals::Proposal.published
                                                .not_hidden
        locale = "en"
        available_locales = proposals.first&.organization&.available_locales
        locale = preferred_locale if available_locales.present? && available_locales.include?(preferred_locale)

        authors = proposals.all.map do |proposal|
          proposal.authors.map do |author|
            Author.display_author(author, locale)
          end
        end
        authors.compact.flatten.uniq { |hash| hash[:reference] }
      end

      def self.proposal_author(reference, preferred_locale)
        if Decidim::User.find_by(name: reference) || Decidim::UserGroup.find_by(name: reference)
          author = Decidim::User.find_by(name: reference) || Decidim::UserGroup.find_by(name: reference)
          Author.user_or_group_author(author)
        elsif Decidim::Organization.find_by(reference_prefix: reference)
          author = Decidim::Organization.find_by(reference_prefix: reference)
          locale = author.available_locales.include?(preferred_locale) ? preferred_locale : "en"
          Author.organization_author(author, locale)
        elsif Decidim::Meetings::Meeting.find_by(reference:)
          author = Decidim::Meetings::Meeting.find_by(reference:)
          locale = author.organization.available_locales.include?(preferred_locale) ? preferred_locale : "en"
          Author.meeting_author(author, locale)
        end
      end

      def self.display_author(author, locale)
        if author.instance_of?(Decidim::Organization)
          Author.organization_author(author, locale)
        elsif author.instance_of?(Decidim::Meetings::Meeting)
          Author.meeting_author(author, locale)
        elsif author.instance_of?(Decidim::User) || author.instance_of?(Decidim::UserGroup)
          Author.user_or_group_author(author)
        end
      end

      def self.organization_author(author, locale)
        { reference: author.reference_prefix,
          name: author.name[locale],
          source: author.official_url }
      end

      def self.meeting_author(author, locale)
        { reference: author.reference,
          name: author.title[locale],
          source: Decidim::ResourceLocatorPresenter.new(author).url }
      end

      def self.user_or_group_author(author)
        { reference: author.name,
          name: author.name,
          source: author.personal_url }
      end
    end
  end
end

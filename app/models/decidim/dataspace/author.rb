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

      def self.from_proposals
        proposals = Decidim::Proposals::Proposal.all.map { |proposal|
          proposal.authors.map do |author|
            if author.instance_of?(Decidim::Organization)
              Author.organization_author(author)
            elsif author.instance_of?(Decidim::Meetings::Meeting)
              Author.meeting_author(author)
            elsif author.instance_of?(Decidim::User) || author.instance_of?(Decidim::UserGroup)
              Author.user_or_group_author(author)
            end
          end
        }
        proposals.flatten.compact.uniq { |hash| hash[:reference] }
      end

      def self.proposal_author(reference)
        if Decidim::User.find_by(name: reference) || Decidim::UserGroup.find_by(name: reference)
          author = Decidim::User.find_by(name: reference) || Decidim::UserGroup.find_by(name: reference)
          return Author.user_or_group_author(author)
        elsif Decidim::Organization.find_by(reference_prefix: reference)
          author = Decidim::Organization.find_by(reference_prefix: reference)
          return Author.organization_author(author)
        elsif Decidim::Meetings::Meeting.find_by(reference: reference)
          author = Decidim::Meetings::Meeting.find_by(reference: reference)
          return Author.meeting_author(author)
        end
      end

      def self.organization_author(author)
        { reference: author.reference_prefix,
          name: author.name["en"],
          source: author.official_url
        }
      end

      def self.meeting_author(author)
        { reference: author.reference,
          name: author.title["en"],
          source: Decidim::ResourceLocatorPresenter.new(author).url
        }
      end

      def self.user_or_group_author(author)
        { reference: author.name,
          name: author.name,
          source: author.personal_url
        }
      end
    end
  end
end

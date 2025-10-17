# frozen_string_literal: true

module Decidim
  module Dataspace
    class Container < Decidim::Dataspace::Interoperable
      self.table_name = "dataspace_containers"

      belongs_to :interoperable, inverse_of: :container, class_name: "Decidim::Dataspace::Interoperable", dependent: :destroy
      belongs_to :parent, class_name: "Decidim::Dataspace::Container", inverse_of: :children, optional: true
      has_many :children, foreign_key: "parent_id", class_name: "Decidim::Dataspace::Container", inverse_of: :parent, dependent: :destroy
      has_many :contributions, dependent: :destroy, class_name: "Decidim::Dataspace::Contribution"

      delegate :reference, :source, :metadata, :created_at, :updated_at, :deleted_at, to: :interoperable

      def self.from_proposals(preferred_locale)
        proposals = Decidim::Proposals::Proposal.published
                                                .not_hidden
                                                .only_amendables
        locale = "en"
        available_locales = proposals.first&.organization&.available_locales
        locale = preferred_locale if available_locales.present? && available_locales.include?(preferred_locale)

        proposals.map do |proposal|
          Container.from_proposal(proposal, locale)
        end.uniq { |hash| hash[:reference] }
      end

      def self.from_params(ref, preferred_locale)
        container = Decidim::Assembly.find_by(reference: ref).presence || Decidim::ParticipatoryProcess.find_by(reference: ref).presence
        return nil unless container

        locale = container.organization.available_locales.include?(preferred_locale) ? preferred_locale : "en"
        {
          "reference": container.reference,
          "source": Decidim::ResourceLocatorPresenter.new(container).url,
          "name": container.title[locale],
          "description": container.description[locale],
          "metadata": {},
          "created_at": container.created_at,
          "updated_at": container.updated_at,
          "deleted_at": nil
        }
      end

      def self.from_proposal(proposal, locale)
        component = proposal.component
        container = component.participatory_space_type.constantize.find(component.participatory_space_id)

        {
          "reference": container.reference,
          "source": Decidim::ResourceLocatorPresenter.new(container).url,
          "name": container.title[locale],
          "description": container.description[locale],
          "metadata": {},
          "created_at": container.created_at,
          "updated_at": container.updated_at,
          "deleted_at": nil
        }
      end
    end
  end
end

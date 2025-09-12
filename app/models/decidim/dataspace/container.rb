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

      def self.from_proposals
        Decidim::Proposals::Proposal.all.map do |proposal|
          Container.from_proposal(proposal)
        end.uniq { |hash| hash[:reference] }
      end

      def self.from_params(params)
        container = Decidim::Assembly.find_by(reference: params).presence || Decidim::ParticipatoryProcess.find_by(reference: params).presence
        return nil unless container

        {
          "reference": container.reference,
          "source": Decidim::ResourceLocatorPresenter.new(container).url,
          "name": container.title["en"],
          "description": container.description["en"],
          "metadata": {},
          "created_at": container.created_at,
          "updated_at": container.updated_at,
          "deleted_at": nil
        }
      end

      def self.from_proposal(proposal)
        container = proposal.component.participatory_space_type.constantize.find(proposal.component.participatory_space_id)

        {
          "reference": container.reference,
          "source": Decidim::ResourceLocatorPresenter.new(container).url,
          "name": container.title["en"],
          "description": container.description["en"],
          "metadata": {},
          "created_at": container.created_at,
          "updated_at": container.updated_at,
          "deleted_at": nil
        }
      end
    end
  end
end

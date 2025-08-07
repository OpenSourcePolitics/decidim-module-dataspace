# frozen_string_literal: true

module Decidim
  module Dataspace
    class Container < Decidim::Dataspace::Interoperable
      self.table_name = "dataspace_containers"

      belongs_to :parent, class_name: "Decidim::Dataspace::Container", inverse_of: :children, optional: true
      has_many :children, class_name: "Decidim::Dataspace::Container", inverse_of: :parent, dependent: :destroy
      has_many :contributions, dependent: :destroy
    end
  end
end

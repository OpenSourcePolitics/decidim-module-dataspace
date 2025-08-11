# frozen_string_literal: true

module Decidim
  module Dataspace
    class Interoperable < ApplicationRecord
      self.table_name = "dataspace_interoperables"

      validates :reference, :source, presence: true
      validates :reference, uniqueness: true
      validates :source, url: true

      has_one :container, class_name: "Decidim::Dataspace::Container"
      has_one :contribution, class_name: "Decidim::Dataspace::Contribution"
      has_one :author, class_name: "Decidim::Dataspace::Author"
    end
  end
end

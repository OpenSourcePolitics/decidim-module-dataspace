# frozen_string_literal: true

module Decidim
  module Dataspace
    class Interoperable < ApplicationRecord
      self.table_name = "dataspace_interoperables"

      validates :reference, :source, presence: true
      validates :reference, uniqueness: true
      validates :source, url: true

      has_one :container, inverse_of: :interoperable, class_name: "Decidim::Dataspace::Container", dependent: nil
      has_one :contribution, inverse_of: :interoperable, class_name: "Decidim::Dataspace::Contribution", dependent: nil
      has_one :author, inverse_of: :interoperable, class_name: "Decidim::Dataspace::Author", dependent: nil
    end
  end
end

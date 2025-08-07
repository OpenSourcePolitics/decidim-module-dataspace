# frozen_string_literal: true

module Decidim
  module Dataspace
    class Interoperable < ApplicationRecord
      self.table_name = "dataspace_interoperables"

      validates :reference, :source, presence: true
    end
  end
end

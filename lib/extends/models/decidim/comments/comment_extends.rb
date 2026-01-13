# frozen_string_literal: true

require "active_support/concern"

module CommentExtends
  extend ActiveSupport::Concern

  included do
    include Decidim::HasReference
    # we can't include HasComponent because it needs a decidim_component_id column
    # instead we override the reference_generator in order to add the proper reference
  end
end

Decidim::Comments::Comment.include(CommentExtends)

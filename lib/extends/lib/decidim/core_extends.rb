# frozen_string_literal: true

require "active_support/concern"

module CoreExtends
  extend ActiveSupport::Concern

  included do
    # we can't include HasComponent to comment because it needs a decidim_component_id column
    # instead we override the reference_generator in order to add the proper reference
    config_accessor :reference_generator do
      lambda do |resource, component|
        ref = ""

        if resource.is_a?(Decidim::HasComponent) && component.present?
          # It is a component resource
          ref = component.participatory_space.organization.reference_prefix
        elsif resource.is_a?(Decidim::Comments::Comment) && component.present?
          # It is a comment resource
          ref = component.participatory_space.organization.reference_prefix
        elsif resource.is_a?(Decidim::Participable)
          # It is a participatory space
          ref = resource.organization.reference_prefix
        end

        class_identifier = resource.class.name.demodulize[0..3].upcase
        year_month = (resource.created_at || Time.current).strftime("%Y-%m")

        [ref, class_identifier, year_month, resource.id].join("-")
      end
    end
  end
end

Decidim.include(CoreExtends)

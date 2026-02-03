# frozen_string_literal: true

module RegisterOrganizationFormExtends
  extend ActiveSupport::Concern

  included do
    attribute :enable_dataspace, Decidim::AttributeObject::TypeMap::Boolean
  end
end

Decidim::System::RegisterOrganizationForm.include(RegisterOrganizationFormExtends)

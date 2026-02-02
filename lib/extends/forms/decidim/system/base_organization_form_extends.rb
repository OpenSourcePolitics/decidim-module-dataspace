# frozen_string_literal: true

module BaseOrganizationFormExtends
  extend ActiveSupport::Concern

  included do
    attribute :enable_dataspace, Decidim::AttributeObject::TypeMap::Boolean
  end
end

Decidim::System::BaseOrganizationForm.include(BaseOrganizationFormExtends)

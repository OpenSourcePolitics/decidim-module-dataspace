# frozen_string_literal: true

module UpdateOrganizationFormExtends
  extend ActiveSupport::Concern

  included do
    attribute :enable_dataspace, Decidim::AttributeObject::TypeMap::Boolean
  end
end

Decidim::System::UpdateOrganizationForm.include(UpdateOrganizationFormExtends)

# frozen_string_literal: true

module CreateOrganizationExtends
  extend ActiveSupport::Concern

  included do
    def create_organization
      Decidim::Organization.create!(
        name: { form.default_locale => form.name },
        host: form.host,
        secondary_hosts: form.clean_secondary_hosts,
        reference_prefix: form.reference_prefix,
        available_locales: form.available_locales,
        available_authorizations: form.clean_available_authorizations,
        external_domain_allowlist: ["decidim.org", "github.com"],
        users_registration_mode: form.users_registration_mode,
        force_users_to_authenticate_before_access_organization: form.force_users_to_authenticate_before_access_organization,
        badges_enabled: true,
        user_groups_enabled: true,
        default_locale: form.default_locale,
        omniauth_settings: form.encrypted_omniauth_settings,
        smtp_settings: form.encrypted_smtp_settings,
        send_welcome_notification: true,
        file_upload_settings: form.file_upload_settings.final,
        colors: default_colors,
        content_security_policy: form.content_security_policy,
        enable_dataspace: form.enable_dataspace
      )
    end
  end
end

Decidim::System::CreateOrganization.include(CreateOrganizationExtends)

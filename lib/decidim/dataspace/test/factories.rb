# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"

FactoryBot.define do
  # factory :dataspace_component, parent: :component do
  #  name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :dataspace).i18n_name }
  #  manifest_name :dataspace
  #  participatory_space { create(:participatory_process, :with_steps) }
  # end

  # Add engine factories here
  factory :interoperable, class: "Decidim::Dataspace::Interoperable" do
    sequence(:reference) { |n| "ref-#{n}" }
    source { "https://example.com/" }
    deleted_at { nil }
    metadata { {} }

    trait :reference_nil do
      reference { nil }
    end

    trait :source_nil do
      source { nil }
    end
  end

  factory :container, class: "Decidim::Dataspace::Container" do
    name { "Space 1" }
    description { "This is the first participatory space.\nIt allows users to contribute and discuss various topics." }
    parent_id { nil }

    transient do
      reference { "B01" }
      source { "https://example.com/" }
      metadata { { "type" => "participatory_process", "visibility" => "public", "status" => "published" } }
    end

    interoperable { build(:interoperable, reference:, source:, metadata:) }
  end

  factory :author_one, class: "Decidim::Dataspace::Author" do
    name { "Jane Doe" }

    transient do
      reference { "A01" }
      source { "https://example.com/account/janedoe" }
    end

    interoperable { build(:interoperable, reference:, source:) }
  end

  factory :author_two, class: "Decidim::Dataspace::Author" do
    name { "John Smith" }

    transient do
      reference { "A02" }
      source { "https://example.com/account/johnsmith" }
    end

    interoperable { build(:interoperable, reference:, source:) }
  end

  factory :contribution, class: "Decidim::Dataspace::Contribution" do
    title { "Contribution 1" }
    content { "Contenu de la contribution 1" }
    locale { "fr" }
    parent { nil }
    association :container

    transient do
      reference { "C01" }
      source { "https://example.com/contribution/1" }
      metadata { { "status" => "published", "type" => "proposal" } }
    end

    interoperable { build(:interoperable, reference:, source:, metadata:) }

    trait :contrib_one do
      after :create do |contribution, _evaluator|
        contribution.authors << create(:author_one)
      end
    end

    trait :contrib_two do
      after :create do |contribution|
        contribution.authors << create(:author_two)
      end
    end

    trait :with_two_authors do
      after :create do |contribution|
        contribution.authors << create(:author_one)
        contribution.authors << create(:author_two)
      end
    end

    trait :with_parent do
      after :create do |contribution|
        contribution.parent = create(:contribution, reference: "C22", source: "https://example.com/contribution/22")
      end
    end
  end

  factory :parent_contrib, class: "Decidim::Dataspace::Contribution" do
    title { "Ma contribution" }
    content { "Contenu de la contribution" }
    locale { "fr" }
    parent { nil }
    container { nil }

    transient do
      reference { "C02" }
      source { "https://example.com/contribution/2" }
      metadata { { "status" => "published", "type" => "proposal" } }
    end

    interoperable { build(:interoperable, reference:, source:, metadata:) }
  end
end

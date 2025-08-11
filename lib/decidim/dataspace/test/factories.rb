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
    reference { "I01" }
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

    transient do
      reference { "B01" }
      source { "https://example.com/" }
      metadata { { "type" => "participatory_process", "visibility" => "public", "status" => "published" } }
    end

    interoperable { build(:interoperable, reference: reference, source: source, metadata: metadata) }
  end

  factory :author_one, class: "Decidim::Dataspace::Author" do
    name { "Jane Doe" }

    transient do
      reference { "A01" }
      source { "https://example.com/account/janedoe" }
    end

    interoperable { build(:interoperable, reference: reference, source: source) }
  end

  factory :author_two, class: "Decidim::Dataspace::Author" do
    name { "John Smith" }

    transient do
      reference { "A02" }
      source { "https://example.com/account/johnsmith" }
    end

    interoperable { build(:interoperable, reference: reference, source: source) }
  end

  factory :contribution, class: "Decidim::Dataspace::Contribution" do
    title { "Contribution 1" }
    content { "Contenu de la contribution 1" }
    locale { "fr" }
    association :container

    transient do
      reference { "C01" }
      source { "https://example.com/contribution/1" }
      metadata { { "status" => "published", "type" => "proposal" } }
    end

    interoperable { build(:interoperable, reference: reference, source: source, metadata: metadata) }

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
        contribution.parent = build(:contribution, reference: "C22", source: "https://example.com/contribution/22")
      end
    end
  end
end

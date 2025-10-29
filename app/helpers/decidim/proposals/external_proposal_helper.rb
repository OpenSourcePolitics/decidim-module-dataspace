# frozen_string_literal: true

module Decidim
  module Proposals
    module ExternalProposalHelper
      def external_state_item(state)
        return if state["state"].blank?

        if state["withdrawn"] == true
          content_tag(:span, humanize_proposal_state(:withdrawn), class: "label alert")
        elsif state["emendation"] == true
          content_tag(:span, humanize_proposal_state(state["state"].capitalize), class: "label #{external_state_class(state)}")
        else
          content_tag(:span, translated_attribute(state["state"].capitalize), class: "label", style: external_css_style(state))
        end
      end

      def external_state_class(state)
        return "alert" if state["withdrawn"] == "true"

        case state["state"]
        when "accepted"
          "success"
        when "rejected"
          "alert"
        when "evaluating"
          "warning"
        else
          "muted"
        end
      end

      def external_css_style(state)
        case state["state"]
        when "accepted"
          "background-color: #E3FCE9; color: #15602C; border-color: #15602C;"
        when "rejected"
          "background-color: #FFEBE9; color: #D1242F; border-color: #D1242F;"
        when "evaluating"
          "background-color: #FFF1E5; color: #BC4C00; border-color: #BC4C00;"
        else
          ""
        end
      end
    end
  end
end

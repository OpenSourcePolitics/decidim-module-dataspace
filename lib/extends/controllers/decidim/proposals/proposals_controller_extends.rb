# frozen_string_literal: true

require "active_support/concern"

module ProposalsControllerExtends
  extend ActiveSupport::Concern

  included do
    def index
      if component_settings.participatory_texts_enabled?
        @proposals = Decidim::Proposals::Proposal.where(component: current_component)
                                                 .published
                                                 .not_hidden
                                                 .only_amendables
                                                 .includes(:category, :scope, :attachments, :coauthorships)
                                                 .order(position: :asc)
        render "decidim/proposals/proposals/participatory_texts/participatory_text"
      else
        if component_settings.add_integration && component_settings.integration_url.present? && data

          external_proposals = data["contributions"]
          @platform = component_settings.integration_url.split("//")[1]
          @authors = data["authors"]
          proposals = search.result
          proposals = reorder(proposals.includes(:component, :coauthorships, :attachments))
          @total_count = proposals.size + external_proposals.size
          @current_page = params[:page].to_i
          @current_page = 1 if @current_page < 1
          @total_pages = (@total_count.to_f / per_page).ceil
          @proposals, @external_proposals = define_proposals_and_external_proposals(proposals, external_proposals, @current_page, per_page)
          # Create a pagination object for view
          @pagination = create_pagination_object(@total_count, @current_page, per_page)
        else
          @proposals = search.result
          @proposals = reorder(@proposals)
          @proposals = paginate(@proposals)
          @proposals = @proposals.includes(:component, :coauthorships, :attachments)
        end

        @voted_proposals = voted_proposals
      end
    end

    def external_proposal
      @external_proposal = GetDataFromApi.contribution(component_settings.integration_url, params[:reference], component_settings.preferred_locale || "en", "true")
      return if @external_proposal.nil?

      @comments = @external_proposal["children"]
      @parent_comments = @comments.select { |comment| comment["parent"] == @external_proposal["reference"] } if @comments
      @authors = GetDataFromApi.authors(component_settings.integration_url, component_settings.preferred_locale || "en")
                               .select { |author| @external_proposal["authors"].include?(author["reference"]) }
                               .map { |author| author["name"] }.join(", ")
    end

    private

    def voted_proposals
      if current_user
        Decidim::Proposals::ProposalVote.where(
          author: current_user,
          proposal: @proposals.pluck(:id)
        ).pluck(:decidim_proposal_id)
      else
        []
      end
    end

    def data
      @data ||= GetDataFromApi.data(component_settings.integration_url, component_settings.preferred_locale || "en").presence
    end

    def define_proposals_and_external_proposals(proposals, external_proposals, current_page, per_page)
      @proposals = []
      @external_proposals = []
      offset = (current_page - 1) * per_page
      total_proposals = proposals.size
      if offset < total_proposals
        # Only proposals on page
        proposals_to_show = [per_page, total_proposals - offset].min
        @proposals = proposals.offset(offset).limit(proposals_to_show)

        # proposals + external_proposals
        remaining_slots = per_page - proposals_to_show
        @external_proposals = external_proposals[0, remaining_slots] || [] if remaining_slots.positive?
      else
        # Only external_proposals
        external_offset = offset - total_proposals
        @external_proposals = external_proposals[external_offset, per_page] || []
      end
      [@proposals, @external_proposals]
    end

    def create_pagination_object(total_count, current_page, per_page)
      Kaminari.paginate_array([], total_count:)
              .page(current_page).per(per_page)
    end
  end
end

Decidim::Proposals::ProposalsController.include(ProposalsControllerExtends)

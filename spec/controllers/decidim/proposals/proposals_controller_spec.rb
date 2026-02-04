# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalsController do
      routes { Decidim::Proposals::Engine.routes }

      let(:component) { create(:proposal_component, :with_geocoding_enabled) }
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:proposal_params) do
        {
          component_id: component.id
        }
      end
      let(:params) { { proposal: proposal_params } }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        stub_const("Decidim::Paginable::OPTIONS", [100])
      end

      describe "GET index" do
        context "when participatory texts are enabled" do
          let(:component) { create(:proposal_component, :with_participatory_texts_enabled) }

          it "sorts proposals by position" do
            get :index
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:participatory_text)
            expect(assigns(:proposals).order_values.first.expr.name).to eq("position")
          end

          context "when emendations exist" do
            let!(:amendable) { create(:proposal, component:) }
            let!(:emendation) { create(:proposal, component:) }
            let!(:amendment) { create(:amendment, amendable:, emendation:, state: "accepted") }

            it "does not include emendations" do
              get :index
              expect(response).to have_http_status(:ok)
              emendations = assigns(:proposals).select(&:emendation?)
              expect(emendations).to be_empty
            end
          end
        end

        context "when participatory texts are disabled" do
          context "and dataspace is disabled" do
            let!(:geocoded_proposals) { create_list(:proposal, 10, component:, latitude: 1.1, longitude: 2.2) }
            let!(:proposals) { create_list(:proposal, 2, component:, latitude: nil, longitude: nil) }

            before do
              get :index
            end

            it "sorts proposals by search defaults" do
              expect(response).to have_http_status(:ok)
              expect(subject).to render_template(:index)
              expect(assigns(:proposals).size).to eq(12)
              expect(assigns(:proposals).order_values).to eq(["position(decidim_proposals_proposals.id::text in '#{assigns(:proposals).ids.join(",")}')"])
            end

            it "sets two different collections" do
              expect(assigns(:proposals)).to match_array(geocoded_proposals + proposals)
            end
          end

          context "and dataspace is enabled" do
            let!(:proposals) { create_list(:proposal, 2, component:) }

            before do
              component.organization.enable_dataspace = true
              component.organization.save!
            end

            context "and there are no external proposals" do
              it "returns proposals" do
                get :index
                expect(response).to have_http_status(:ok)
                expect(subject).to render_template(:index)
                expect(assigns(:proposals).size).to eq(2)
                expect(assigns(:proposals).order_values).to eq(["position(decidim_proposals_proposals.id::text in '#{assigns(:proposals).ids.join(",")}')"])
              end
            end

            context "and there are externals proposals" do
              let(:component) { create(:proposal_component) }
              let!(:proposals) { create_list(:proposal, 2, component:) }
              let(:contrib_one) do
                { "reference": "JD-PROP-2025-09-1",
                  "source": "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
                  "container": "JD-PART-2025-09-1",
                  "locale": "en",
                  "title": "Test one",
                  "content": "Debitis repellat provident",
                  "authors": ["JD-MEET-2025-09-6"],
                  "created_at": "2025-09-11T10:20:21.222Z",
                  "updated_at": "2025-09-11T10:21:56.604Z",
                  "deleted_at": nil }
              end
              let(:contrib_two) do
                { "reference": "JD-PROP-2025-09-20",
                  "source": "http://localhost:3000/assemblies/smile-trivial/f/25/proposals/20",
                  "container": "JD-ASSE-2025-09-1",
                  "locale": "en",
                  "title": "Test two",
                  "content": "Non et vel",
                  "authors": ["JD-MEET-2025-09-23"],
                  "created_at": "2025-09-11T10:43:23.743Z",
                  "updated_at": "2025-09-11T10:43:27.147Z",
                  "deleted_at": nil }
              end
              let(:container_one) do
                {
                  "reference": "JD-PART-2025-09-1",
                  "source": "http://localhost:3000/processes/satisfaction-hope",
                  "name": "Cupiditate natus dignissimos saepe ut.",
                  "description": "<p>Voluptas recusandae est. Nesciunt excepturi corrupti. Qui natus eligendi.</p>",
                  "metadata": {},
                  "created_at": "2025-09-11T10:14:58.111Z",
                  "updated_at": "2025-09-11T10:14:58.126Z",
                  "deleted_at": nil
                }
              end
              let(:container_two) do
                {
                  "reference": "JD-ASSE-2025-09-1",
                  "source": "http://localhost:3000/assemblies/smile-trivial",
                  "name": "Molestiae aut corporis quas et.",
                  "description": "<p>Ratione autem repellendus. Error voluptatem ipsam. Ut dicta velit.</p>",
                  "metadata": {},
                  "created_at": "2025-09-11T10:38:07.682Z",
                  "updated_at": "2025-09-11T10:38:07.682Z",
                  "deleted_at": nil
                }
              end
              let(:author_one) do
                {
                  "reference": "JD-MEET-2025-09-6",
                  "name": "Animi voluptatum.",
                  "source": "http://localhost:3000/processes/satisfaction-hope/f/5/meetings/6"
                }
              end
              let(:author_two) do
                {
                  "reference": "JD-MEET-2025-09-23",
                  "name": "Et natus.",
                  "source": "http://localhost:3000/assemblies/smile-trivial/f/23/meetings/23"
                }
              end

              let(:json) do
                {
                  "containers" => [container_one, container_two],
                  "contributions" => [contrib_one, contrib_two],
                  "authors" => [author_one, author_two]
                }
              end

              context "and there is one url in integration url" do
                before do
                  component.update!(settings: { add_integration: true, integration_url: "http://example.org", preferred_locale: "en" })
                  allow(GetDataFromApi).to receive(:data).and_return(json)
                end

                it "sorts proposals by search defaults and define external_proposals and other variables" do
                  get :index
                  expect(response).to have_http_status(:ok)
                  expect(subject).to render_template(:index)
                  expect(assigns(:proposals).order_values).to eq ["position(decidim_proposals_proposals.id::text in '#{assigns(:proposals).ids.join(",")}')"]
                  expect(assigns(:authors).count).to eq 2
                  expect(assigns(:authors).first[:reference]).to eq "JD-MEET-2025-09-6"
                  expect(assigns(:authors).last[:reference]).to eq "JD-MEET-2025-09-23"
                  expect(assigns(:total_count)).to eq 4
                  expect(assigns(:current_page)).to eq 1
                  expect(assigns(:total_pages)).to eq 1
                  expect(assigns(:proposals).count).to eq 2
                  expect(assigns(:external_proposals).count).to eq 2
                  expect(assigns(:external_proposals).first[:reference]).to eq "JD-PROP-2025-09-1"
                  expect(assigns(:external_proposals).last[:reference]).to eq "JD-PROP-2025-09-20"
                end
              end

              context "and there are 2 urls in integration_url" do
                before do
                  component.update!(settings: { add_integration: true, integration_url: "http://example.org, http://example.org,", preferred_locale: "en" })
                  allow(GetDataFromApi).to receive(:data).and_return(json)
                end

                it "returns 4 external proposals and 4 authors" do
                  get :index
                  expect(response).to have_http_status(:ok)
                  expect(subject).to render_template(:index)
                  expect(assigns(:external_proposals).count).to eq 4
                  expect(assigns(:authors).count).to eq 4
                end
              end
            end
          end
        end
      end

      describe "GET external_proposal" do
        let(:component) { create(:proposal_component) }
        let(:json_contrib) do
          {
            "reference" => "JD-PROP-2025-09-1",
            "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
            "container" => "JD-PART-2025-09-1",
            "locale" => "en",
            "title" => "Quia sapiente.",
            "content" => "Debitis repellat provident. Earum dolorem eaque. Aut quia officiis.\nAsperiores cupiditate accusantium. Esse rerum quia. Atque et distinctio.",
            "authors" => [
              "JD-MEET-2025-09-23"
            ],
            "parent" => nil,
            "children" => [
              {
                "reference" => "JD-PROP-2025-09-1-249",
                "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
                "container" => "JD-PART-2025-09-1",
                "locale" => "en",
                "title" => nil,
                "content" => "Cumque hic quia veniam et dolores aliquam commodi laudantium omnis expedita enim natus et beatae quidem dolores architecto repudiandae rem a corporis impedit rerum fugit neque eos dicta deserunt consequatur numquam magnam voluptate inventore omnis aut porro nemo voluptas sit quia saepe aut provident accusantium voluptatem illum nam quaerat molestiae.",
                "authors" => "Kautzer-Mayer",
                "parent" => "JD-PROP-2025-09-1",
                "children" => [
                  "JD-PROP-2025-09-1-250"
                ],
                "metadata" => {
                  "depth" => 0
                },
                "created_at" => "2025-09-11T10:20:23.609Z",
                "updated_at" => "2025-09-11T10:20:23.609Z",
                "deleted_at" => nil
              },
              {
                "reference" => "JD-PROP-2025-09-1-250",
                "source" => "http://localhost:3000/processes/satisfaction-hope/f/7/proposals/1",
                "container" => "JD-PART-2025-09-1",
                "locale" => "en",
                "title" => nil,
                "content" => "Voluptatem illum sit eius eligendi omnis dolore qui alias et occaecati eos ipsum blanditiis unde fugit minus est quia excepturi eos ut nam iste molestias cupiditate et vel repellat quidem qui non est porro commodi quia mollitia reiciendis odit rem voluptas tempora autem et sequi quos provident accusantium fugiat accusamus.",
                "authors" => "Aldo Davis",
                "parent" => "JD-PROP-2025-09-1-249",
                "children" => nil,
                "metadata" => {
                  "depth" => 1
                },
                "created_at" => "2025-09-11T10:20:24.655Z",
                "updated_at" => "2025-09-11T10:20:24.655Z",
                "deleted_at" => nil
              }
            ],
            "created_at" => "2025-09-11T10:20:21.222Z",
            "updated_at" => "2025-09-11T10:21:56.604Z",
            "deleted_at" => nil
          }
        end

        let(:authors) do
          [
            {
              "reference" => "JD-MEET-2025-09-23",
              "name" => "Et natus.",
              "source" => "http://localhost:3000/assemblies/smile-trivial/f/23/meetings/23"
            },
            {
              "reference" => "Aldo Davis",
              "name" => "Aldo Davis",
              "source" => nil
            },
            {
              "reference" => "Kautzer-Mayer",
              "name" => "Kautzer-Mayer",
              "source" => nil
            },
            {
              "reference" => "JD",
              "name" => "Gislason LLC",
              "source" => nil
            }
          ]
        end

        before do
          component.update!(settings: { add_integration: true, integration_url: "http://example.org", preferred_locale: "en" })
          allow(GetDataFromApi).to receive(:contribution).and_return(json_contrib)
          allow(GetDataFromApi).to receive(:authors).and_return(authors)
        end

        context "when dataspace is disabled" do
          it "redirects to proposals index" do
            get :external_proposal, params: { reference: "JD-PROP-2025-09-1", param: :reference, url: "http://example.org" }
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to("/proposals")
          end
        end

        context "when dataspace is enabled" do
          before do
            component.organization.enable_dataspace = true
            component.organization.save!
          end

          it "displays external_proposal view and sets variables" do
            get :external_proposal, params: { reference: "JD-PROP-2025-09-1", param: :reference, url: "http://example.org" }
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:external_proposal)
            expect(assigns(:external_proposal)).to eq json_contrib
            expect(assigns(:comments)).to eq json_contrib["children"]
            expect(assigns(:parent_comments)).to eq(json_contrib["children"].select { |comment| comment["parent"] == json_contrib["reference"] })
            expect(assigns(:authors)).to eq "Et natus."
          end
        end
      end

      describe "GET new" do
        let(:component) { create(:proposal_component, :with_creation_enabled) }

        before { sign_in user }

        context "when NO draft proposals exist" do
          it "renders the empty form" do
            get(:new, params:)
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:new)
          end
        end

        context "when draft proposals exist from other users" do
          let!(:others_draft) { create(:proposal, :draft, component:) }

          it "renders the empty form" do
            get(:new, params:)
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:new)
          end
        end
      end

      context "when user is not logged in" do
        let(:component) { create(:proposal_component, :with_creation_enabled) }

        it "redirects to the login page" do
          get(:new)
          expect(response).to have_http_status(:found)
          expect(response.body).to have_text("You are being redirected")
        end
      end

      describe "POST create" do
        before { sign_in user }

        context "when creation is not enabled" do
          let(:component) { create(:proposal_component) }

          it "raises an error" do
            post(:create, params:)

            expect(flash[:alert]).not_to be_empty
          end
        end

        context "when creation is enabled" do
          let(:component) { create(:proposal_component, :with_creation_enabled) }
          let(:proposal_params) do
            {
              component_id: component.id,
              title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
              body: "Ut sed dolor vitae purus volutpat venenatis. Donec sit amet sagittis sapien. Curabitur rhoncus ullamcorper feugiat. Aliquam et magna metus."
            }
          end

          it "creates a proposal" do
            post(:create, params:)

            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end
      end

      describe "PATCH update" do
        let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed) }
        let(:proposal) { create(:proposal, component:, users: [user]) }
        let(:proposal_params) do
          {
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
            body: "Ut sed dolor vitae purus volutpat venenatis. Donec sit amet sagittis sapien. Curabitur rhoncus ullamcorper feugiat. Aliquam et magna metus."
          }
        end
        let(:params) do
          {
            id: proposal.id,
            proposal: proposal_params
          }
        end

        before { sign_in user }

        it "updates the proposal" do
          patch(:update, params:)

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end

        context "when the existing proposal has attachments and there are other errors on the form" do
          include_context "with controller rendering the view" do
            let(:proposal_params) do
              {
                title: "Short",
                # When the proposal has existing photos or documents, their IDs
                # will be sent as Strings in the form payload.
                photos: proposal.photos.map { |a| a.id.to_s },
                documents: proposal.documents.map { |a| a.id.to_s }
              }
            end
            let(:proposal) { create(:proposal, :with_photo, :with_document, component:, users: [user]) }

            it "displays the editing form with errors" do
              patch(:update, params:)

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:ok)
              expect(subject).to render_template(:edit)
              expect(response.body).to include("There was a problem saving")
            end
          end
        end
      end

      describe "access links from creating proposal steps" do
        let!(:component) { create(:proposal_component, :with_creation_enabled) }
        let!(:current_user) { create(:user, :confirmed, organization: component.organization) }
        let!(:proposal_extra) { create(:proposal, :draft, component:, users: [current_user]) }
        let!(:params) do
          {
            id: proposal_extra.id,
            proposal: proposal_params
          }
        end

        before { sign_in user }

        context "when you try to preview a proposal created by another user" do
          it "will not render the preview page" do
            get(:preview, params:)
            expect(subject).not_to render_template(:preview)
          end
        end

        context "when you try to publish a proposal created by another user" do
          it "will not render the publish page" do
            post(:publish, params:)
            expect(subject).not_to render_template(:publish)
          end
        end
      end

      describe "withdraw a proposal" do
        let(:component) { create(:proposal_component, :with_creation_enabled) }

        before { sign_in user }

        context "when an authorized user is withdrawing a proposal" do
          let(:proposal) { create(:proposal, component:, users: [user]) }

          it "withdraws the proposal" do
            put :withdraw, params: params.merge(id: proposal.id)

            expect(flash[:notice]).to eq("Proposal successfully updated.")
            expect(response).to have_http_status(:found)
            proposal.reload
            expect(proposal).to be_withdrawn
          end

          context "and the proposal already has votes" do
            let(:proposal) { create(:proposal, :with_votes, component:, users: [user]) }

            it "is not able to withdraw the proposal" do
              put :withdraw, params: params.merge(id: proposal.id)

              expect(flash[:alert]).to eq("This proposal cannot be withdrawn because it already has votes.")
              expect(response).to have_http_status(:found)
              proposal.reload
              expect(proposal).not_to be_withdrawn
            end
          end
        end

        describe "when current user is NOT the author of the proposal" do
          let(:current_user) { create(:user, :confirmed, organization: component.organization) }
          let(:proposal) { create(:proposal, component:, users: [current_user]) }

          context "and the proposal has no votes" do
            it "is not able to withdraw the proposal" do
              expect(WithdrawProposal).not_to receive(:call)

              put :withdraw, params: params.merge(id: proposal.id)

              expect(flash[:alert]).to eq("You are not authorized to perform this action.")
              expect(response).to have_http_status(:found)
              proposal.reload
              expect(proposal).not_to be_withdrawn
            end
          end
        end
      end

      describe "GET show" do
        let!(:component) { create(:proposal_component, :with_amendments_enabled) }
        let!(:amendable) { create(:proposal, component:) }
        let!(:emendation) { create(:proposal, component:) }
        let!(:amendment) { create(:amendment, amendable:, emendation:) }
        let(:active_step_id) { component.participatory_space.active_step.id }

        context "when the proposal is an amendable" do
          it "shows the proposal" do
            get :show, params: params.merge(id: amendable.id)
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:show)
          end

          context "and the user is not logged in" do
            it "shows the proposal" do
              get :show, params: params.merge(id: amendable.id)
              expect(response).to have_http_status(:ok)
              expect(subject).to render_template(:show)
            end
          end
        end

        context "when the proposal is an emendation" do
          context "and amendments VISIBILITY is set to 'participants'" do
            before do
              component.update!(step_settings: { active_step_id => { amendments_visibility: "participants" } })
            end

            context "when the user is not logged in" do
              it "redirects to 404" do
                expect do
                  get :show, params: params.merge(id: emendation.id)
                end.to raise_error(ActionController::RoutingError)
              end
            end

            context "when the user is logged in" do
              before { sign_in user }

              context "and the user is the author of the emendation" do
                let(:user) { amendment.amender }

                it "shows the proposal" do
                  get :show, params: params.merge(id: emendation.id)
                  expect(response).to have_http_status(:ok)
                  expect(subject).to render_template(:show)
                end
              end

              context "and is NOT the author of the emendation" do
                it "redirects to 404" do
                  expect do
                    get :show, params: params.merge(id: emendation.id)
                  end.to raise_error(ActionController::RoutingError)
                end

                context "when the user is an admin" do
                  let(:user) { create(:user, :admin, :confirmed, organization: component.organization) }

                  it "shows the proposal" do
                    get :show, params: params.merge(id: emendation.id)
                    expect(response).to have_http_status(:ok)
                    expect(subject).to render_template(:show)
                  end
                end
              end
            end
          end

          context "and amendments VISIBILITY is set to 'all'" do
            before do
              component.update!(step_settings: { active_step_id => { amendments_visibility: "all" } })
            end

            context "when the user is not logged in" do
              it "shows the proposal" do
                get :show, params: params.merge(id: emendation.id)
                expect(response).to have_http_status(:ok)
                expect(subject).to render_template(:show)
              end
            end

            context "when the user is logged in" do
              before { sign_in user }

              context "and is NOT the author of the emendation" do
                it "shows the proposal" do
                  get :show, params: params.merge(id: emendation.id)
                  expect(response).to have_http_status(:ok)
                  expect(subject).to render_template(:show)
                end
              end
            end
          end
        end
      end
    end
  end
end

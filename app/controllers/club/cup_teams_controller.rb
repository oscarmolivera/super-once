module Club
  class CupTeamsController < Club::BaseController
    before_action :set_cup_team, only: %i[show edit update destroy roster]

    def index
      @cup_teams = policy_scope(CupTeam).includes(tournament: :cup, category: :sport_school).order(created_at: :desc)
    end

    def show
      authorize @cup_team
      @team_players = policy_scope(TeamPlayer).where(cup_team: @cup_team).includes(:player).order(:jersey_number, "players.last_name", "players.first_name")
      @matches = policy_scope(Match).where(cup_team: @cup_team).order(:starts_at)
    end

    def new
      @cup_team = CupTeam.new(academy: current_academy)
      if params[:cup_team].present?
        @cup_team.assign_attributes(params.require(:cup_team).permit(:tournament_id, :category_id, :name))
      end
      authorize @cup_team
    end

    def create
      @cup_team = CupTeam.new(cup_team_params.merge(academy: current_academy))
      authorize @cup_team

      if @cup_team.name.blank?
        @cup_team.name = "#{@cup_team.category&.name} — #{@cup_team.tournament&.year}"
      end

      if @cup_team.save
        redirect_to club_cup_team_path(@cup_team), notice: "Squad registered."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @cup_team
    end

    def update
      authorize @cup_team
      if @cup_team.update(cup_team_params)
        redirect_to club_cup_team_path(@cup_team), notice: "Squad updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @cup_team
      @cup_team.destroy
      redirect_to club_cup_teams_path, notice: "Squad deleted."
    end

    # GET/PATCH /club/cup_teams/:id/roster
    def roster
      authorize @cup_team, :roster_edit?

      @players = @cup_team.category.players.order(:last_name, :first_name)
      @existing = policy_scope(TeamPlayer).where(cup_team: @cup_team, player: @players).index_by(&:player_id)

      if request.patch?
        authorize @cup_team, :roster_update?

        TeamPlayer.transaction do
          selected_ids = Array(params[:selected_player_ids]).map(&:to_s)

          # Remove deselected players
          @existing.each do |player_id, tp|
            tp.destroy! unless selected_ids.include?(player_id.to_s)
          end

          # Upsert selected players with jersey/position
          selected_ids.each do |pid|
            player = @players.detect { |p| p.id.to_s == pid }
            next unless player

            jersey = params.dig(:roster, pid, :jersey_number).presence
            position = params.dig(:roster, pid, :position).to_s.presence

            tp = TeamPlayer.find_or_initialize_by(academy: current_academy, cup_team: @cup_team, player: player)
            tp.jersey_number = jersey
            tp.position = position
            authorize tp, :upsert?
            tp.save!
          end
        end

        redirect_to roster_club_cup_team_path(@cup_team), notice: "Roster saved."
      end
    end

    private

    def set_cup_team
      @cup_team = policy_scope(CupTeam).find(params[:id])
    end

    def cup_team_params
      params.require(:cup_team).permit(:tournament_id, :category_id, :name)
    end
  end
end


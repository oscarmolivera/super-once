module Club
  class MatchesController < Club::BaseController
    before_action :set_match, only: %i[show edit update destroy]

    def index
      @matches = policy_scope(Match).includes(:cup_team, tournament: :cup).order(starts_at: :desc).limit(200)
    end

    def show
      authorize @match
    end

    def new
      @match = Match.new(academy: current_academy, status: :scheduled, home: true)
      authorize @match
    end

    def create
      @match = Match.new(match_params.merge(academy: current_academy))
      authorize @match

      if @match.save
        redirect_to club_match_path(@match), notice: "Match created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @match
    end

    def update
      authorize @match
      if @match.update(match_params)
        redirect_to club_match_path(@match), notice: "Match updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @match
      @match.destroy
      redirect_to club_matches_path, notice: "Match deleted."
    end

    private

    def set_match
      @match = policy_scope(Match).find(params[:id])
    end

    def match_params
      params.require(:match).permit(
        :tournament_id, :cup_team_id,
        :opponent_name, :starts_at, :venue, :home, :status,
        :home_score, :away_score, :notes
      )
    end
  end
end


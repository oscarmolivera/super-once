module Club
  class TournamentsController < Club::BaseController
    before_action :set_cup, only: %i[new create]
    before_action :set_tournament, only: %i[show edit update destroy]

    def index
      @tournaments = policy_scope(Tournament).includes(:cup).order(year: :desc, starts_on: :desc)
    end

    def show
      authorize @tournament
      @cup_teams = policy_scope(CupTeam).where(tournament: @tournament).includes(:category).order(:name)
      @matches = policy_scope(Match).where(tournament: @tournament).includes(:cup_team).order(:starts_at)
    end

    def new
      @tournament = Tournament.new(academy: current_academy, cup: @cup, year: Date.current.year)
      authorize @tournament
    end

    def create
      @tournament = Tournament.new(tournament_params.merge(academy: current_academy, cup: @cup))
      authorize @tournament

      if @tournament.save
        redirect_to club_tournament_path(@tournament), notice: "Tournament created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @tournament
    end

    def update
      authorize @tournament
      if @tournament.update(tournament_params)
        redirect_to club_tournament_path(@tournament), notice: "Tournament updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @tournament
      @tournament.destroy
      redirect_to club_cup_path(@tournament.cup), notice: "Tournament deleted."
    end

    private

    def set_cup
      @cup = policy_scope(Cup).find(params[:cup_id])
    end

    def set_tournament
      @tournament = policy_scope(Tournament).find(params[:id])
    end

    def tournament_params
      params.require(:tournament).permit(:year, :starts_on, :ends_on, :location)
    end
  end
end


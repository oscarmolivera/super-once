module School
  class PlayersController < School::BaseController
    before_action :set_player, only: %i[show edit update destroy]

    def index
      @players = policy_scope(Player).order(:last_name, :first_name)
    end

    def show
      authorize @player
      @enrollments = @player.category_enrollments.includes(:category).order(created_at: :desc)
    end

    def new
      @player = Player.new(academy: current_academy)
      authorize @player
    end

    def create
      @player = Player.new(player_params.merge(academy: current_academy))
      authorize @player

      if @player.save
        redirect_to school_player_path(@player), notice: "Player registered."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @player
    end

    def update
      authorize @player
      if @player.update(player_params)
        redirect_to school_player_path(@player), notice: "Player updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @player
      @player.destroy
      redirect_to school_players_path, notice: "Player removed."
    end

    private

    def set_player
      @player = policy_scope(Player).find(params[:id])
    end

    def player_params
      params.require(:player).permit(
        :first_name, :last_name, :birth_date,
        :guardian_name, :guardian_phone, :guardian_email,
        :photo_url
      )
    end
  end
end


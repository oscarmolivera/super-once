module Club
  class CupsController < Club::BaseController
    before_action :set_cup, only: %i[show edit update destroy]

    def index
      @cups = policy_scope(Cup).order(:sport_type, :name)
    end

    def show
      authorize @cup
      @tournaments = policy_scope(Tournament).where(cup: @cup).order(year: :desc)
    end

    def new
      @cup = Cup.new(academy: current_academy, sport_type: current_academy.sport_type, recurring: true)
      authorize @cup
    end

    def create
      @cup = Cup.new(cup_params.merge(academy: current_academy))
      authorize @cup

      if @cup.save
        redirect_to club_cup_path(@cup), notice: "Cup created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @cup
    end

    def update
      authorize @cup
      if @cup.update(cup_params)
        redirect_to club_cup_path(@cup), notice: "Cup updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @cup
      @cup.destroy
      redirect_to club_cups_path, notice: "Cup deleted."
    end

    private

    def set_cup
      @cup = policy_scope(Cup).find(params[:id])
    end

    def cup_params
      params.require(:cup).permit(:name, :organizer, :sport_type, :recurring)
    end
  end
end


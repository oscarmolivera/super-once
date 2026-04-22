module School
  class CategoriesController < School::BaseController
    before_action :set_category, only: %i[show edit update destroy]

    def index
      @categories = policy_scope(Category).includes(:sport_school).order(:name)
    end

    def show
      authorize @category
      @players = @category.players.order(:last_name, :first_name)
      @coaches = @category.coaches.ordered
    end

    def new
      @category = Category.new(academy: current_academy)
      authorize @category
    end

    def create
      @category = Category.new(category_params.merge(academy: current_academy))
      authorize @category

      if @category.save
        redirect_to school_category_path(@category), notice: "Category created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @category
    end

    def update
      authorize @category
      if @category.update(category_params)
        redirect_to school_category_path(@category), notice: "Category updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @category
      @category.destroy
      redirect_to school_categories_path, notice: "Category deleted."
    end

    private

    def set_category
      @category = policy_scope(Category).find(params[:id])
    end

    def category_params
      params.require(:category).permit(:sport_school_id, :name, :min_age, :max_age)
    end
  end
end


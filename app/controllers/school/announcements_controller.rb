module School
  class AnnouncementsController < School::BaseController
    before_action :set_announcement, only: %i[show edit update destroy]

    def index
      @announcements = policy_scope(Announcement).includes(:category).order(published_at: :desc, created_at: :desc).limit(200)
    end

    def show
      authorize @announcement
    end

    def new
      @announcement = Announcement.new(academy: current_academy, published_at: Time.current)
      authorize @announcement
    end

    def create
      @announcement = Announcement.new(announcement_params.merge(academy: current_academy))
      authorize @announcement

      if @announcement.save
        redirect_to school_announcement_path(@announcement), notice: "Announcement posted."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @announcement
    end

    def update
      authorize @announcement
      if @announcement.update(announcement_params)
        redirect_to school_announcement_path(@announcement), notice: "Announcement updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @announcement
      @announcement.destroy
      redirect_to school_announcements_path, notice: "Announcement deleted."
    end

    private

    def set_announcement
      @announcement = policy_scope(Announcement).find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(:category_id, :title, :body, :published_at)
    end
  end
end


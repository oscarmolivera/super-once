class AcademySettingsController < ApplicationController
  before_action :set_academy

  def show
    authorize @academy, :settings_show?
  end

  def edit
    authorize @academy, :settings_edit?
  end

  def update
    authorize @academy, :settings_update?

    if @academy.update(academy_settings_params)
      redirect_to academy_settings_path, notice: "Settings updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_academy
    @academy = current_academy
  end

  def academy_settings_params
    params.require(:academy).permit(
      :name, :description, :city, :country,
      :phone, :website, :primary_color, :sport_type
    )
  end
end

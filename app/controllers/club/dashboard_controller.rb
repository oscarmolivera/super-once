module Club
  class DashboardController < ApplicationController
    def index
      authorize :club_dashboard, :index?
    end
  end
end

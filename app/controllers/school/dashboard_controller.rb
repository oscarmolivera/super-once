module School
  class DashboardController < ApplicationController
    def index
      authorize :school_dashboard, :index?
    end
  end
end

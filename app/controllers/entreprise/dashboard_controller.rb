module Enterprise
  class DashboardController < ApplicationController
    def index
      authorize :enterprise_dashboard, :index?
    end
  end
end

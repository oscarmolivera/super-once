module School
  class BaseController < ApplicationController
    layout "application"

    helper_method :school_nav_items, :current_employee

    private

    def school_nav_items
      [
        { path: school_root_path,              label: "Overview",      icon: "academic-cap" },
        { path: school_categories_path,        label: "Categories",    icon: "rectangle-stack" },
        { path: school_players_path,           label: "Players",       icon: "users" },
        { path: school_practice_sessions_path, label: "Practice",      icon: "calendar-days" },
        { path: school_announcements_path,     label: "Board",         icon: "megaphone" }
      ]
    end

    def current_employee
      return nil unless Current.user && current_academy
      @current_employee ||= Employee.find_by(academy: current_academy, user: Current.user)
    end
  end
end


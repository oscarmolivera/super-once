module Club
  class BaseController < ApplicationController
    layout "application"

    helper_method :club_nav_items

    private

    def club_nav_items
      [
        { path: club_root_path, label: "Overview",   icon: "trophy" },
        { path: club_cups_path, label: "Cups",       icon: "flag" },
        { path: club_tournaments_path, label: "Tournaments", icon: "calendar-days" },
        { path: club_cup_teams_path, label: "Squads", icon: "users" },
        { path: club_matches_path, label: "Matches", icon: "clock" },
      ]
    end
  end
end


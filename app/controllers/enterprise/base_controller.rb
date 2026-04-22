module Enterprise
  class BaseController < ApplicationController
    # All Enterprise controllers inherit from this.
    # It sets the layout breadcrumb context so views know they're inside Enterprise.
    layout "application"

    # Expose a helper so views can render the enterprise nav without repeating code.
    helper_method :enterprise_nav_items

    private

    def enterprise_nav_items
      [
        { path: enterprise_root_path,              label: "Overview",        icon: "chart-bar" },
        { path: enterprise_employees_path,         label: "Employees",       icon: "user-group" },
        { path: enterprise_salaries_path,          label: "Payroll",         icon: "banknotes" },
        { path: enterprise_income_expenses_path,   label: "Finances",        icon: "currency-euro" },
        { path: enterprise_player_payments_path,   label: "Player payments", icon: "credit-card" },
        { path: enterprise_inventory_items_path,   label: "Inventory",       icon: "archive-box" },
        { path: enterprise_tax_permits_path,       label: "Docs & permits",  icon: "document-check" },
      ]
    end
  end
end

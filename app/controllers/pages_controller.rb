# www.nubbe.net — fully public marketing pages, no auth, no tenant
class PagesController < ActionController::Base
  layout "marketing"

  def index;   end
  def about;   end
  def pricing; end
  def contact; end

  # academy.nubbe.net/welcome — public-facing academy landing page.
  # Resolved via the tenant subdomain but requires NO login.
  def academy
    slug     = request.subdomain
    @academy = Academy.find_by(slug: slug)
    redirect_to academy_welcome_path unless @academy
  end
end

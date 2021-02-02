class ApplicationController < ActionController::Base
  include UrlHelper
  include PhoneHelper
  protect_from_forgery
  before_action :set_time_zone

  private

  def set_time_zone
    Time.zone = Rails.configuration.time_zone
  end

  def require_login
    unless logged_in?
      store_location
      redirect_to(login_url, :alert => "Try logging in first.")
    end
  end

  def require_admin
    unless admin?
      if logged_in?
        case request.format
        when Mime::XML, Mime::JSON
          render text: '<htmtl><body>You must be an admin of your account to access this.</body></htmtl>', status: 401
        else
          render :text => 'Nope.'
        end
      else
        require_login
      end
    end
  end

  helper_method :current_user, :logged_in?, :admin?, :sponsors_active?, :sponsors_images?

  def logged_in?
    current_user.present?
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboard_path
  end

  def sponsors_active?
    Rails.configuration.x.stripe.secret_key.present? && Rails.configuration.x.stripe.publishable_key.present?
  end

  def sponsors_images?
    Rails.configuration.x.s3.bucket.present? &&
    Rails.configuration.x.s3.access_key_id.present? &&
    Rails.configuration.x.s3.secret_access_key.present?
  end
end

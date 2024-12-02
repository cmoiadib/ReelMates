class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_signed_in
  before_action :set_action_cable_identifier

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  def check_signed_in
    redirect_to parties_path if signed_in?
  end

  private

  def set_action_cable_identifier
    cookies.signed[:guest_user_id] = current_or_guest_user&.id
  end
end

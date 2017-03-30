class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale

  private

  def set_locale
    I18n.locale = params[:locale] if ['pt', 'en'].include? params[:locale]
  end

  def default_url_options(options = {})
    { locale: I18n.locale }
  end
end

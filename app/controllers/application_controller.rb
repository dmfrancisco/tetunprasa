class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale

  private

  def set_locale
    I18n.locale = params[:locale] == 'pt' ? :pt : :en
  end

  def default_url_options(options = {})
    params[:locale] == 'pt' ? { locale: 'pt' } : {}
  end
end

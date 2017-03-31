class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale

  private

  def set_locale
    if  ['pt', 'en'].include? params[:locale]
      I18n.locale = params[:locale]
    else
      I18n.locale = 'en'
    end
  end

  def default_url_options(options = {})
    params[:locale] == 'pt' ? { locale: 'pt' } : {}
  end
end

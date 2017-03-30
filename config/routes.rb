Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  scope "(:locale)", locale: /pt/ do
    root 'dictionary#index'
  end
end

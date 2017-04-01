Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  authenticated do
    scope "(:locale)", locale: /pt/ do
      root 'dictionary#index'
    end
  end

  unauthenticated do
    root 'dictionary#index'
  end
end

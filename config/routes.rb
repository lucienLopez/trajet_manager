Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'trajets', to: 'trajets#create'
  post 'trajets/:code/start', to: 'trajets#start'
  post 'trajets/:code/cancel', to: 'trajets#cancel'
end

Rails.application.routes.draw do
  resource :profile, only: [ :show ]
  resources :events

  root "events#index"
  get "sign_out", to: "sessions#destroy", as: :sign_out
  delete "sign_out", to: "sessions#destroy"

  get "up" => "rails/health#show", as: :rails_health_check
  get "/.well-known/appspecific/com.chrome.devtools.json", to: proc { [ 204, {}, [] ] }
  post "/webhooks/clerk", to: "webhooks/clerk#create"

  namespace :api do
    namespace :v1 do
      resources :events
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end

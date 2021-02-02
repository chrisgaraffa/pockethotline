PocketHotline::Application.routes.draw do
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root :to => "pages#index"


  get "volunteer", :to => "pages#volunteer"
  get "volunteers", :to => "pages#volunteers"
  get 'dashboard' => "pages#dashboard", :as => 'dashboard'
  get 'charge', :to => "how#charge"

  post "twilio/start", :as => :twilio_start
  post "twilio/operator_answer", :as => :twilio_operator_answer
  post "twilio/operator_response", :as => :twilio_operator_response
  post "twilio/caller_hangup", :as => :twilio_caller_hangup

  post "twilio/answer", :as => :twilio_answer
  post "twilio/no_answer_or_completed", :as => :no_answer_or_completed
  post "twilio/finish", :as => :twilio_finish
  post "twilio/caller_review", :as => :twilio_caller_review

#  delete "logout" => "sessions#destroy"
#  get "login" => "sessions#new"
#  get "forgot_password" => "sessions#forgot_password", :as => "forgot_password"
#  post "request_password_reset" => "sessions#request_password_reset", :as => "request_password_reset"

  #get 'join' => "users#apply", :as => 'join'
  #get "set-password/:token" => "users#set_password", :as => "set_password"
  #get 'unsubscribe/:token' => 'users#unsubscribe', :as => "unsubscribe"

  get 'settings' => 'users#edit', :id => 'current'

  get 'widget' => "share#widget"
  get 'share' => "share#widget"
  put 'share/update_widget' => "share#update_widget"

  #resources :sessions
  resources :calls do
    resources :comments
  end
  post 'calls/log_notes'
  
  resources :users do
    collection do
      #get 'apply'
      #get 'apply_thanks'
    end
    member do
      post 'toggle_status'
      get 'edit_on_call_status'
      #post 'approve'
      #put 'save_password'
    end
    resources :oncall_schedules, :only => [:index, :create] do
      collection do
        get 'all'
      end
    end
  end

  resources :services # so i can do new_service_path

  resources :twitter_accounts, :only => [:new, :edit, :update, :destroy] do
    collection do
      get 'callback'
    end
  end

  resources :pages, :only => [] do
    collection do
      get 'remove_image'
    end
  end

  resources :sponsors, :except => [:delete], :path => :supporters
  get '/support', :to => 'sponsors#new'

  get "/c/:call_token", :to => "reviews#new"

  resources :callcategories do
    collection do
      post 'reorder'
    end
    member do
      patch 'toggle_active'
    end
  end
  

  resources :reviews, :only => [:new, :create] do
    collection do
      get 'thanks'
    end
  end
end

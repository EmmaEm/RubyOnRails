Rails.application.routes.draw do
  get 'welcome/index'
  resources :articles
  root 'welcome#index'

  get 'calendars/weekly_schedule'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

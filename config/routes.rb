Rails.application.routes.draw do
  get '/' => 'meetings#index'
  get '/meetings' => 'meetings#index'
  get '/meetings/new' => 'meetings#new'
  post '/meetings' => 'meetings#create'
  get '/meetings/:id/edit' => 'meetings#edit'
  patch '/meetings/:id' => 'meetings#update'
  patch '/meetings/:id/teachers/:teacher_id' => 'meetings#add_teacher'
  patch '/required' => 'meetings#required'

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
end

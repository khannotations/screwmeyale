Screwyale::Application.routes.draw do
  match 'logout' => 'main#logout'
  match 'uncas' => "main#uncas"
  match 'all' => "main#all"
  match 'about' => "main#about"

  match "new" => "screwconnectors#create"
  match "delete" => "screwconnectors#destroy"
  match 'match/:id' => 'screwconnectors#show'
  match 'sc/info' => 'screwconnectors#info', :via => [:post]
  
  match 'auth' => 'users#auth'
  match 'info' => 'users#info'
  match 'whois' => "users#whois", :via => [:post]

  match 'request' => "requests#create", :via => [:post]
  match 'request/deny' => "requests#deny", :via => [:post]
  match 'request/accept' => "requests#accept", :via => [:post]
  match 'request/delete' => "requests#delete", :via => [:post]


  root :to => 'main#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

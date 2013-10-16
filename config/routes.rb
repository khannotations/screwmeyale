Screwyale::Application.routes.draw do

  root :to => 'main#index'
  
  # match 'logout' => 'main#logout'
  # match 'uncas' => "main#uncas"
  # match 'all' => "main#all"
  get 'about' => 'main#about'

  # match "new" => "screwconnectors#create"
  # match "delete" => "screwconnectors#destroy"
  # match 'match/:id' => 'screwconnectors#show'
  # match 'sc/info' => 'screwconnectors#info', :via => [:post]
  
  # match 'auth' => 'users#auth'
  # match 'info' => 'users#info'
  # match 'whois' => "users#whois", :via => [:post]

  # match 'request' => "requests#create", :via => [:post]
  # match 'request/deny' => "requests#deny", :via => [:post]
  # match 'request/accept' => "requests#accept", :via => [:post]
  # match 'request/delete' => "requests#delete", :via => [:post]

  # match 'google7604c73f5d884a98.html' => "main#google"

  # match 'screwers' => "main#index"
  # match 'screws' => "main#index"
  # match 'profile' => "main#index"
  # match 'requests' => "main#index"

  # match '*' => 'main#index'

end

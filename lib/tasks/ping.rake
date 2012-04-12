desc "Ping the site"
task :ping => :environment do
  r = Net::Ping::HTTP.new("http://screwmeyale.heroku.com", 80, 5)
  r.ping()
end

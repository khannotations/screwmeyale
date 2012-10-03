desc "Change all last names to title case"
task :fix_names => :environment do

  User.all.each do |u|

    u.lname = u.lname.titlecase
    u.save
  end

end
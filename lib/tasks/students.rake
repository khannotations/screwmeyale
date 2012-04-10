desc "Get all students and put them in database"
task :get_students => :environment do
    f = File.open("/Users/fzkhan2007/yale.txt", "r")
    count  = 0
    while (line = f.gets)
      count += 1
      if line.length > 1

        p = line.split(" | ")
        User.create!(
          fname: p[0], lname: p[1], nickname: p[0], 
          email: p[2], college: p[3], year: p[4], picture: p[5]
        )
      end
    end
end
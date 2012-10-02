desc "Read file and make users"
task :populate => :environment do

  f = File.open("yale2012-2013.txt", "r")

  f.each do |line|
    opts = line.split(" | ")
    User.create!({
        fname: opts[0],
        nickname: opts[0],
        lname: opts[1],
        email: opts[2],
        college: opts[3],
        year: opts[4],
        picture: opts[5]
      })
  end

end
desc "Scrape Yale Facebook and get all users"
task :get_users => :environment do
  require 'rubygems'
  require 'open-uri'
  require 'nokogiri'
  require 'mechanize'

  agent = Mechanize.new
  agent.user_agent_alias = "Mac Safari"
  url = "https://students.yale.edu/facebook/PhotoPage"
  new_url = "https://students.yale.edu/facebook/ChangeCollege?newOrg="
  all_url = "https://students.yale.edu/facebook/PhotoPage?currentIndex=-1&numberToGet=-1"
  agent.get(url)

  form = agent.page.forms.first
  STDOUT.print "Enter your Yale NetID: "
  form.username = STDIN.gets.strip
  STDOUT.print "Enter your NetID Password: "
  form.password = STDIN.gets.strip
  form.submit
  
  colleges = {
    "Berkeley%20College" => "Berkeley College",
    "Branford%20College" => "Branford College",
    "Calhoun%20College"  => "Calhoun College",
    "Davenport%20College" => "Davenport College",
    "Ezra%20Stiles%20College" => "Ezra Stiles College",
    "Jonathan%20Edwards%20College" => "Jonathan Edwards College",
    "Morse%20College" => "Morse College",
    "Pierson%20College" => "Pierson College",
    "Saybrook%20College" => "Saybrook College",
    "Silliman%20College" => "Silliman College",
    "Timothy%20Dwight%20College" => "Timothy Dwight College",
    "Trumbull%20College" => "Trumbull College" }

  colleges.each do |urlPart,college|
    puts "Getting #{college} students' information..."
    frontPage = agent.get(new_url + urlPart)
    frontPage = agent.get(all_url)

    students = agent.page.search(".student_container")
    students.each do |student|
      begin
        name = student.css(".student_name")[0].text.strip
        nameParts = name.match /([[:alpha:]]+),\s*([[:alpha:]]+)\s*([[:alpha:]]*)/
        fname = $2
        lname = $1
        email = student.css(".student_info > a")[0].text.strip
        year  = student.css(".student_year")[0].text.strip
        year[0] = ''
        pictureUrl = student.css("img")[0]["src"]
        # puts "#{fname}|#{lname}|#{email}|#{year}|#{pictureUrl}"
        User.create!({
          fname: fname,
          nickname: fname,
          lname: lname,
          email: email,
          college: college,
          year: "20#{year}",
          picture: "https://students.yale.edu#{pictureUrl}"
        })
      rescue
        puts "Could not add student #{name}"
      end
    end
  end
  puts "DONE!!"
end

desc "Scrape Yale Facebook and get all users"
task :get_users => :environment do

  require 'rubygems'
  require 'open-uri'
  require 'nokogiri'
  require 'mechanize'

  agent = Mechanize.new
  agent.user_agent_alias = "Mac Safari"
  url = "https://students.yale.edu/facebook/PhotoPage"
  new_url = "https://students.yale.edu/facebook/ChangeCollege?newOrg=Yale%20College"
  agent.get(url)

  f = Nokogiri::HTML(open(url))

  form = agent.page.forms.first
  form.username = "fak23"
  form.password = "mathgeek142"
  form.submit

  #puts agent.page.inspect
  agent.get(new_url)
  count = 0
  # f = File.open("yale.txt", "w")
  l = agent.page.link_with(:text => "Next >")
  flag = true
  while flag
    flag  = false if not l
    items = agent.page.search("tr:nth-child(3) td , tr:nth-child(4) td, tr:nth-child(5) td")

    items.css("td").each do |i|
      begin
        names = i.at_css("b").text.split(",")
        fname = names[1].split(" ")[0].strip
        lname = names[0].strip
      rescue 
        puts "\t\t\t\t\t\tNO NAME"
        next
      end
      year = i.text[/'\d\d/]
      if year == ""
        year = "Unknown"
        puts "\t\t\t\t\t\tNO YEAR"
      end
      c = i.text[/(Morse|Jonathan Edwards|Davenport|Trumbull|Calhoun|Pierson|Silliman|Saybrook|Branford|Berkeley|Ezra Stiles|Timothy Dwight)/]
      if c == ""
        c = "Unknown"
        puts "\t\t\t\t\t\tNO COLLEGE"
      end
      begin
        email = i.at("a").text
      rescue 
        email = "#{fname.downcase}.#{lname.sub(' ','').downcase}@yale.edu"
        puts "\t\t\t\t\t\tNO EMAIL"
      end
      begin
        image = i.at_css("img")["src"]
      rescue 
        image = "/facebook/Photo?id=0"
        puts "\t\t\t\t\t\tNO IMAGE"
      end
      
      User.create!({
        fname: fname,
        nickname: fname,
        lname: lname,
        email: email,
        college: c,
        year: year,
        picture: "https://students.yale.edu#{image}"
      })
      # f.puts "#{fname} | #{lname} | #{email} | #{c} | #{year} | https://students.yale.edu#{image} | #{count}\n"
      puts "#{count}: Wrote #{fname} #{lname}"
      count+=1
    end
    # f.flush()
    if l
      puts l.href
      l.click()
      l = agent.page.link_with(:text => "Next >")
    else
      puts "DONE!!\n\n"
    end
  end

  # f.close()
end


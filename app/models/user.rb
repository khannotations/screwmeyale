class User < ActiveRecord::Base
  require 'net/ldap'
  require 'mechanize'

  has_many :screwconnectors, :foreign_key => "screw_id" # connectors in which user is screw
  has_many :screwerconnectors, :class_name => "Screwconnector", :foreign_key => "screwer_id" # connectors in which user is screwer

  has_many :screwers, :through => :screwconnectors # People screwing user
  has_many :screws, :through => :screwerconnectors # People user is screwing

  has_many :got_requests, :through => :screwerconnectors
  has_many :sent_requests, :through => :screwerconnectors

  validates :fname, :presence => true
  validates :lname, :presence => true
  validates :email, :presence => true, :uniqueness => {:case_sensitive => false, :message => "Must have unique email"}


  # CLASS VARIABLES

  @@students = []

  @@majors = ['African American Studies', 
    'African Studies', 'American Studies', 'Anthropology', 'Applied Mathematics', 
    'Applied Physics', 'Archaeological Studies', 'Architecture', 'Art', 
    'Astronomy', 'Astronomy and Physics', 'Biology', 'Chemistry', 'Chinese', 
    'Classical Civilization', 'Classics (Greek)', 'Classics (Greek and Latin)', 
    'Classics (Latin)', 'Cognitive Science', 'Computer Science', 
    'Computer Science and Mathematics', 'Computer Science and Psychology', 
    'Computing and the Arts', 'East Asian Studies', 'Economics', 
    'Economics and Mathematics', 'Electrical Engineering and Computer Science', 
    'Engineering', 'Biomedical Engineering', 'Chemical Engineering', 
    'Electrical Engineering', 'Environmental Engineering', 
    'Mechanical Engineering', 'English', 'Environmental Studies', 
    'Ethics, Politics, and Economics', 'Ethnicity, Race, and Migration', 
    'Film Studies', 'French', 'Geology and Geophysics', 
    'Germanic Languages and Literatures', 'German Studies', 'Global Affairs', 
    'Greek, Ancient and Modern', 'History', 'History of Art', 
    'History of Science', 'History of Medicine', 'Humanities', 'Global Health', 
    'Italian', 'Japanese', 'Judaic Studies', 'Latin American Studies', 
    'Linguistics', 'Literature', 'Mathematics', 'Mathematics and Philosophy', 
    'Mathematics and Physics', 'Modern Middle East Studies', 
    'Molecular Biophysics and Biochemistry', 'Music', 
    'Near Eastern Languages and Civilizations', 'Philosophy', 'Physics', 
    'Physics and Philosophy', 'Political Science', 'Portuguese', 'Psychology', 
    'Religious Studies', 'Russian', 'Russian and East European Studies', 
    'Sociology', 'South Asian Studies', 'Spanish', 'Special Divisional Major', 
    'Statistics', 'Theater Studies', 'Undecided', "Women's, Gender, and Sexuality Studies"]

  @@college_array = {
    "Berkeley College" => "BK", 
    "Branford College" => "BR",
    "Calhoun College" => "CC", 
    "Davenport College" => "DC", 
    "Ezra Stiles College" => "ES",
    "Jonathan Edwards College" => "JE", 
    "Morse College" => "MC", 
    "Pierson College" => "PC",
    "Saybrook College" => "SY",
    "Silliman College" => "SM", 
    "Timothy Dwight College" => "TD", 
    "Trumbull College" => "TC"
  }


  # All sent requests
  def get_sent
    self.sent_requests.includes({:to => :screw}, {:from => :screw}).where(accepted: nil).order("to_id")
  end

  # All received requests
  def get_got
    self.got_requests.includes({:to => :screw}, {:from => :screw}).where(accepted: nil).order("to_id")
  end

  def get_past_sent
    self.sent_requests.includes({:to => :screw}, {:from => :screw}).where("accepted = ? OR accepted = ?", true, false).order("updated_at DESC")
  end

  def get_past_got
    self.got_requests.includes({:to => :screw}, {:from => :screw}).where("accepted = ? OR accepted = ?", true, false).order("updated_at DESC")
  end

  def history
    self.screwconnectors.includes({:match => :screw}, :screw).where("match_id > '0'").order("updated_at")
  end

  def fullname
    "#{self.nickname} #{self.lname}"
  end

  def lengthy_name
    part = ""
    if self.nickname != self.fname
      part = "#{self.fname} \"#{self.nickname}\" #{self.lname}"
    else
      part = self.fullname
    end

    return "#{part} (#{self.short_college} #{self.short_year})"

  end


  # Should be in helper, but couldn't get it to work and gave up
  def make_select
    college = self.college
    text = 
    "<select name='event'>\
    <option value='#{college} Screw 2012'>#{college} 2012</option>"
    if self.year == "'15"
      text += "<option value='Freshman Screw 2013'>Freshman 2013</option>"
    end
    text += "</select>"
    text
  end

  # Stringify the preference
  def pref
    p = self.preference
    return "boys" if p == 1
    return "girls" if p == 2
    return "boys and girls" if p == 3
    return "other lames"
  end

  # Stringify the gender
  def gen
    g = self.gender
    return "boy" if g == 1
    return "girl" if g == 2
    return "lame" # Sass in case they bypassed gender specs
  end


  def User.make_names
    @@students = []
    User.all.each do |u|
      if not @@students.include? u.lengthy_name
        @@students << u.lengthy_name
      else
        puts "\n\nTHE WILD CHANCE THAT THERE ARE TWO PEOPLE IN THE SAME COLLEGE \
        AND YEAR WITH THE SAME FIRST AND LAST NAME HAS BEEN REALIZED WTF YALE ADMISSIONS?!\n\n"
      end
    end
    return
  end

  def User.all_names
    @@students
  end

  def short_college
    @@college_array[self.college]
  end

  def short_year
    self.year.gsub(/20/, "'")
  end

  # Gets the user from the lengthy name, the inverse of lengthy name
  def User.identify name
    college_year_regex = / \((\w\w) '(\d\d)\)/
    nickname_regex = /"(\w|-)+"/

    cy = college_year_regex.match(name)
    return nil if not cy
    college = User.long_college cy[1]
    year = "20"+cy[2]

    name = name.gsub(college_year_regex, "") # Remove college, year junk  
    name = name.gsub(nickname_regex, "").split(" ")

    # Now 'name' is an array 
    fname = name[0]
    lname = name[1, 5].join(" ") # the rest — not sure why i chose 5?

    @user = User.where(fname: fname, lname: lname, college: college, year: year).first

  end
  
  def User.majors
    @@majors
  end

  def User.long_college college
    @@college_array.each do |key, value|
      return key if value == college
    end
  end

  # Fetches user email from Yale directory

  def User.get_user netid
    email_regex = /^\s*Email Address:\s*$/i
    browser = User.make_cas_browser
    browser.get("http://directory.yale.edu/phonebook/index.htm?searchString=uid%3D#{netid}")
    u = nil
    browser.page.search('tr').each do |tr|
      puts "tr!"
      field = tr.at('th').text
      value = tr.at('td').text.strip
      case field
      when email_regex
        u =  User.where(email: value).first
        if u
          u.netid = netid
          u.save
        end
      end
    end
    u
  end

  def User.make_cas_browser
    browser = Mechanize.new
    browser.get( 'https://secure.its.yale.edu/cas/login' )
    form = browser.page.forms.first
    # If you're seeing this, please don't hack me...
    form.username = "fak23"
    form.password = ENV['CAS_PASS']
    form.submit
    browser
  end

  # SETUP 
  User.make_names

  # Fetches user email from Yale LDAP
  # DOESN'T WORK NO MORE :(
  def User.ldap netid
    email = ""
    begin
      ldap = Net::LDAP.new( :host =>"directory.yale.edu" , :port =>"389" )
      f = Net::LDAP::Filter.eq('uid', netid)

      b = 'ou=People,o=yale.edu'
      p = ldap.search(:base => b, :filter => f, :return_result => true).first

      email = p['mail']
      logger.debug :text => "LDAP EMAIL: --#{email}--"
    rescue Exception => e
      logger.debug :text => e
      logger.debug :text => "*** ERROR with LDAP"
    end
    u = User.where(email: email).first
    if u
      u.netid = netid
      u.save
    end
    u
  end
end

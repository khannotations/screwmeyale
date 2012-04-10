class Screwconnector < ActiveRecord::Base
  belongs_to :screwer, :class_name => "User" # Person screwing
  belongs_to :screw, :class_name => "User" # Person being screwed
  belongs_to :match, :class_name => "Screwconnector" # The screw with whom this screw was matched, if any (default is 0, i.e. unmatched)

  has_many :sent_requests, :class_name => "Request", :foreign_key => "from_id", :dependent => :delete_all
  has_many :got_requests, :class_name => "Request", :foreign_key => "to_id", :dependent => :delete_all

  validates :event, :presence => "true"
  validates :intensity, :presence => "true"
  validates :screw_id, :presence => "true"
  validates :screwer_id, :presence => "true"

  def find_all_screws
    p = self.screw
    all = Screwconnector.includes(:screw).where(match_id: 0);
    matches = []
    if p.preference == 3
      all.each do |a|
        s = a.screw
        matches.append(a) if (s.preference == p.gender or s.preference == 3) and s != p
      end
    else
      all.each do |a|
        s = a.screw
        matches.append(a) if (s.preference == p.gender or s.preference == 3) and s.gender == p.preference and s != p
      end
    end
    matches
  end


  def find_all_matches
    # Get all users that match preferences
    # Differentiate between those which are being screwed (the screw of at least one screwconnector) and those who aren't
      # of the former, find those who haven't been matched for the event you're going for

    p = self.screw;
    my_id = self.screwer_id;
    if p.preference == 3
      # Get all users matching preferences that aren't the screw him/herself or the screwer
      all = User.includes({:screwconnectors => :screw}, :screwers).where(["(preference = ? OR preference = 3) AND (id <> ? OR id <> ?)", p.gender, p.id, my_id])
    else
      all = User.includes({:screwconnectors => :screw}, :screwers).where(["(preference = ? OR preference = 3) AND (gender = ?) AND (id <> ? OR id <> ?)", p.gender, p.preference, p.id, my_id])
    end
    matches = []

    all.each do |a|
      puts a.fullname
      sc = a.screwconnectors.first # get all screwers (screwconnectors maps to screwconnectors in which this user is the screw, not the screwer)
      if not sc # the person is not being screwed
        # matches.append({:type => "user", :match => a})
      else # the person is being screwed
        if sc.match_id == 0 # and has not been matched
          matches.append({:type => "sc", :match => sc})
        elsif sc.event != self.event
          matches.append({:type => "user", :match => a})
        end
      end
    end
    matches
  end

  def find_int
    int = self.intensity
    p = self.screw
    all = Screwconnector.includes(:screw).where(["(match_id = 0) AND intensity BETWEEN ? AND ?", (int-2), (int+2)])
    matches = []
    if p.preference == 3
      all.each do |a|
        s = a.screw
        matches.append(a) if (s.preference == p.gender or s.preference == 3) and s != p
      end
    else
      all.each do |a|
        s = a.screw
        matches.append(a) if (s.preference == p.gender or s.preference == 3) and s.gender == p.preference and s != p
      end
    end
    matches
  end

  def find_event
    e = self.event
    p = self.screw
    all = Screwconnector.includes(:screw).where(match_id: 0, event: e)
    matches = []
    if p.preference == 3
      all.each do |a|
        s = a.screw
        matches.append(a) if (s.preference == p.gender or s.preference == 3) and s != p
      end
    else
      all.each do |a|
        s = a.screw
        matches.append(a) if (s.preference == p.gender or s.preference == 3) and s.gender == p.preference and s != p
      end
    end
    matches
  end
end

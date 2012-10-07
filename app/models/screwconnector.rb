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

  def cleanup
    # destroy all the pending requests from this screwconnector
    Request.where(from_id: self, accepted: nil).destroy_all 
    
    recd = Request.where(to_id: self, accepted: nil)
    recd.each do |r|
      r.accepted = false # Reject all the other requests sent to this sc
      r.save
    end
  end

  def short_event
    self.event.gsub(/( College| 20\d\d)/, "")
  end

  # returns an array of [screws, intensity, event, all]
  def find_everything
    # Differentiate between those which are being screwed (the screw of at least one screwconnector) and those who aren't
    # of the former, find those who haven't been matched for the event you're going for

    p = self.screw;
    my_id = self.screwer_id;
    if p.preference == 3
      # Get all users matching preferences that aren't the screw him/herself or the screwer
      all = User.includes({:screwconnectors => :screw}, :screwers).where(["(preference = ? OR preference = 3) AND id <> ? AND id <> ?", p.gender, p.id, my_id]).order("updated_at DESC");
    else
      all = User.includes({:screwconnectors => :screw}, :screwers).where(["(preference = ? OR preference = 3) AND (gender = ?) AND id <> ? AND id <> ?", p.gender, p.preference, p.id, my_id]).order("updated_at DESC");
    end
    all_screw_matches = [] # subset of all matches
    intensity_matches = [] # subset of all_screw matches
    event_matches = []     # subset of all_screw matches
    all_matches = []

    all.each do |a|
      puts a.fullname
      # get all unmatched screwconnector objects in which a is the screw 
      sc = Screwconnector.includes(:screw).where(match_id: 0, screw_id: a.id).first
      if not sc  # the person is not being screwed or already matched
        all_matches.append({:type => "user", :match => a})
      else       # the person is being screwed and unmatched 
        # if the person isn't one of my other screws
        if sc.screwer_id != my_id 
          all_matches.append({:type => "sc", :match => sc})
          all_screw_matches.append(sc)
          intensity_matches.append(sc) if (sc.intensity - self.intensity).abs <= 2
          event_matches.append(sc) if (sc.event == self.event)

        # If they are one of my screws, they should still show up as a person
        elsif sc.event != self.event
          all_matches.append({:type => "user", :match => a})
        end
      end
    end

    return [all_screw_matches, intensity_matches, event_matches, all_matches]
  end


  # def find_all_screws
  #   me = self.screwer
  #   p = self.screw
  #   all = Screwconnector.includes(:screw).where(match_id: 0).order("updated_at DESC");
  #   matches = []
  #   if p.preference == 3
  #     all.each do |a|
  #       s = a.screw
  #       matches.append(a) if (s.preference == p.gender or s.preference == 3) and s != p and s != me 
  #     end
  #   else
  #     all.each do |a|
  #       s = a.screw
  #       matches.append(a) if (s.preference == p.gender or s.preference == 3) and s.gender == p.preference and s != p and s != me
  #     end
  #   end
  #   matches
  # end


  # def find_all_matches
  #   # Get all users that match preferences
  #   # Differentiate between those which are being screwed (the screw of at least one screwconnector) and those who aren't
  #     # of the former, find those who haven't been matched for the event you're going for

  #   p = self.screw;
  #   my_id = self.screwer_id;
  #   if p.preference == 3
  #     # Get all users matching preferences that aren't the screw him/herself or the screwer
  #     all = User.includes({:screwconnectors => :screw}, :screwers).where(["(preference = ? OR preference = 3) AND id <> ? AND id <> ?", p.gender, p.id, my_id]).order("updated_at DESC");
  #   else
  #     all = User.includes({:screwconnectors => :screw}, :screwers).where(["(preference = ? OR preference = 3) AND (gender = ?) AND id <> ? AND id <> ?", p.gender, p.preference, p.id, my_id]).order("updated_at DESC");
  #   end
  #   matches = []

  #   all.each do |a|
  #     puts a.fullname
  #     # get all screwers (the method screwconnectors returns screwconnectors in which this user is the screw, not the screwer)
  #     sc = a.screwconnectors.first 
  #     if not sc # the person is not being screwed
  #       matches.append({:type => "user", :match => a})
  #     else # the person is being screwed
  #       if sc.match_id == 0 # and has not been matched
  #         matches.append({:type => "sc", :match => sc})
  #       elsif sc.event != self.event
  #         matches.append({:type => "user", :match => a})
  #       end
  #     end
  #   end
  #   matches
  # end

  # def find_int
  #   int = self.intensity
  #   p = self.screw
  #   all = Screwconnector.includes(:screw).where(["(match_id = 0) AND intensity BETWEEN ? AND ?", (int-2), (int+2)]).order("updated_at DESC");
  #   matches = []
  #   if p.preference == 3
  #     all.each do |a|
  #       s = a.screw
  #       matches.append(a) if (s.preference == p.gender or s.preference == 3) and s != p
  #     end
  #   else
  #     all.each do |a|
  #       s = a.screw
  #       matches.append(a) if (s.preference == p.gender or s.preference == 3) and s.gender == p.preference and s != p
  #     end
  #   end
  #   matches
  # end

  # def find_event
  #   e = self.event
  #   p = self.screw
  #   all = Screwconnector.includes(:screw).where(match_id: 0, event: e).order("updated_at DESC");
  #   matches = []
  #   if p.preference == 3
  #     all.each do |a|
  #       s = a.screw
  #       matches.append(a) if (s.preference == p.gender or s.preference == 3) and s != p
  #     end
  #   else
  #     all.each do |a|
  #       s = a.screw
  #       matches.append(a) if (s.preference == p.gender or s.preference == 3) and s.gender == p.preference and s != p
  #     end
  #   end
  #   matches
  # end
end

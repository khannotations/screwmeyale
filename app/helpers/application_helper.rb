module ApplicationHelper
  def format_since time # in seconds
    time = time.to_f
    tf = time.floor

    text = "just now"
    text = "about #{(time/1.minute).floor} minutes ago" if tf > 5.minutes
    text = "#{pluralize((time/(1.hour)).floor, 'hour')} ago" if tf >= 1.hour
    text = "#{pluralize((time/(1.day)).floor, 'day')} ago" if tf >= 1.day
    text = "#{pluralize((time/(1.week)).floor, 'week')} ago" if tf >= 1.week
    text = "#{pluralize((time/(1.month)).floor, 'month')} ago" if tf >= 1.month
    text = "#{pluralize((time/(1.year)).floor, 'year')} ago" if tf >= 1.year
    text
  end
end

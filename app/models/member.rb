require 'open-uri'
require 'json'
require 'date'

class Member < ActiveRecord::Base
  attr_accessible :karma, :username, :date_registered, :karma_per_day

  def self.users_for_month(month, year)
    start_date = Date.parse("#{year}-#{month}-1")
    end_date = start_date.end_of_month
    Member.where(:date_registered => start_date..end_date).order("karma DESC")
  end

  def self.get_member(username)
    return self.where(:username => username).first
  end
  
  def self.crawl_and_make_users
    url = "http://hnsearch.algolia.com/api/v1/search_by_date?hitsPerPage=100"
    doc = open(url).read
    j = JSON.parse(doc)
    new_members = 0
    updated_karma = 0
    j['hits'].each do |item|
      username = item['author']
      member = get_member(username)
      sleep 4.0 # to be nice to the API provider
      if not member
        self.make_from_api(username)
        new_members += 1
        sleep 4.0 # to be nice to the API provider        
      else
        updated_karma += member.update_karma
      end
    end
    "Saw #{new_members} new users, updated #{updated_karma} users' karma"
  end

  def self.make_from_api(username)
    begin
      url = "http://hnsearch.algolia.com/api/v1/users/" + username
      doc = open(url).read
      j = JSON.parse(doc)
      
      #p j['created_at_i']
      if (j.key?('created_at_i'))
        date_registered = DateTime.strptime(j['created_at_i'].to_s, "%s")
      else 
        puts 'no created_at_i: ' + username
        return
        #date_registered = DateTime.now #TODO: only because data isn't all loaded yet
      end
      
      karma = j['karma']
      date_range = (Date.today - date_registered).to_f
      
      if date_range > 1
        kpd = karma / date_range
      else
        kpd = karma
      end
      
      self.create(
        :username => username,
        :karma => karma,
        :karma_per_day => kpd,
        :date_registered => date_registered
      )
    rescue StandardError => e
      puts "error for username " + username + ": "
      puts e
    end
  end
    
  def update_karma(force=false)
    if updated_at < DateTime.now - 6.hours or force
      url = "http://hnsearch.algolia.com/api/v1/users/" + username 
      doc = open(url).read
      j = JSON.parse(doc)
      self.karma = j['karma']
      day_range = (Date.today - date_registered).to_f
      if day_range > 1
        self.karma_per_day = self.karma / day_range
      else
        self.karma_per_day = self.karma
      end

      begin
        url = "http://karma.hn/" + username   #TODO: this url doesn't exist yet
        doc = open(url).read
        j = JSON.parse(doc)
        self.comment_karma = j['comment_karma']
        self.story_karma = j['story_karma']
      rescue Exception

      end

      save
      touch
      1
    else
      0
    end
  end
  
  def percentile(date=false)
    if date
      start_date = date_registered.beginning_of_month
      end_date = date_registered.end_of_month
      total_users = Member.where(:date_registered => start_date..end_date)
    else
      total_users = Member
    end
    
    population = total_users.count
    below_karma = total_users.where("karma < ?", karma).count
    {"percentile" => (below_karma+1) / population.to_f, # +1 includes the user himself
     "below_karma" => below_karma,
     "population" => population}
  end
  
  def age
    (Date.today - date_registered).to_i
  end
  
  def per_day_percentile
    population = Member.count
    below_karma = Member.where("karma_per_day < ?", karma_per_day).count
    {"percentile" => (below_karma+1) / population.to_f, # +1 includes the user himself
     "below_karma_per_day" => below_karma,
     "population" => population}
  end
  
  def get_width(max_karma)
    if karma < 0
      0
    else
      karma / max_karma.to_f * 100
    end
  end
  
end

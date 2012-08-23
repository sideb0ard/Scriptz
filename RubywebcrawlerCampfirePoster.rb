#!/usr/bin/ruby
require 'rubygems'
require 'mechanize'
require 'tinder'


####### WAITING ROOM DETAILS
loginurl = "URL"
u = "USERNAME"
p = "PASSWORD"

countFile = "/tmp/previousCount"

###### CAMPFIRE DETAILS
apikey = '#########################'
campfire = Tinder::Campfire.new 'YOURSUBDOMAIN', :token => apikey
room = campfire.find_room_by_name 'ROOMNAME'

################### MAIN

a = Mechanize.new
page = a.get(loginurl)
login_form = page.form_with(:action => %r'FORMLOGINACTION')
login_form.field_with(:name => "user").value = u
login_form.field_with(:name => "password").value = p

nextpage = a.submit login_form
waitingroom = a.click(nextpage.link_with(:href => %r'WAITINGROOMURL'))

waitingRoomCount = waitingroom.body.match(/id="waitingRoomCount">(\d+)/).captures
inProcessCount = waitingroom.body.match(/id="inProcessCount">(\d+)/).captures
    
puts "Waiting Room Count is " + waitingRoomCount.to_s + ". InProcess Count is " + inProcessCount.to_s

begin
    previousCountFile = File.open(countFile, "r")
    begin
        previousCount = previousCountFile.readline
    rescue EOFError => e
        previousCount = 0
    end
    previousCountFile.close
    puts "Last result was " + previousCount.to_s
rescue Errno::ENOENT => e
    previousCount = 0
    puts "No file - will use " + previousCount.to_s + " as previousCount"
end    

if previousCount.to_i == 0 and waitingRoomCount.to_s.to_i > 0
    #puts "WAITING ROOM ENGAGED - " + waitingRoomCount.to_s + " now in room"
    room.speak "ROBOT SPEAK:: WAITING ROOM ENGAGED - " + waitingRoomCount.to_s + " now in room"
elsif previousCount.to_i > 0 and waitingRoomCount.to_s.to_i == 0
    #puts "WAITING ROOM DISENGAGED"
    room.speak "ROBOT SPEAK:: Waiting Room Disengaged - hoos is quiet again"
else 
    #puts "NO CHANGE IN ENGAGEMENT"
end

resultsOutput = File.open(countFile, "w")
resultsOutput.puts(waitingRoomCount.to_s)

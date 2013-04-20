#!/usr/bin/env ruby

require 'net/imap'
require 'net/http'
require 'httparty'
require 'json'
require 'mail'
require 'pp'
require 'RMagick'

def handle_message(message)
  events = ::Dog::MailedEvent.find()
  
  subject = message.subject.to_s.encode('UTF-8')

  name = ""
  
  if message.multipart? then
    body = message.text_part.body.to_s.encode('UTF-8') rescue ""
        
    attachment = message.attachments.first
    
    dirname = File.dirname(::Dog::Runtime.bundle_filename)
    
    name = UUID.new.generate
    extension = File.extname(attachment.filename)
    name = name + extension
    
    FileUtils.mkpath(File.join(dirname, "views", "data"))
    path = File.join(dirname, "views", "data", name)
    
    file = File.open(path, "w+") 
    file.write(message.attachments.first.read)
    file.close

    if extension == ".jpg" || extension == ".jpeg" then
      image = Magick::Image.read(path).first
      image = image.auto_orient
      image.write(path)
    end

  else
    body = message.body.to_s.encode('UTF-8') rescue ""
  end

  email = ::Dog::Value.new("dog.email", {})
  email["subject"] = ::Dog::Value.string_value(subject)
  email["body"] = ::Dog::Value.string_value(body)
  email["attachment"] = ::Dog::Value.string_value(name)

  for event in events do
    future = ::Dog::Future.find_one("value_id" => event["channel_id"])
    future = future.value

    track = ::Dog::Track.new
    track.variables["container"] = future
    track.variables["value"] = email

    proc = ::Dog::Library::Dog.package.symbols["add"]["implementations"][0]["instructions"]
    proc.call(track)
  end
  
end

# Time to sleep between polls
SLEEP_TIME = 5

config = ::Dog::Config.get("email")
config = config["imap"]

if config.nil? then
  exit
end

# TODO - Consider migrating everything to the mail gem:
# http://rdoc.info/github/mikel/mail/Mail/IMAP

# this script will continue running forever
loop do
  begin
    # make a connection to imap account
    imap = Net::IMAP.new(config['host'], config['port'], true)
    imap.login(config['user_name'], config['password'])
    
    # select inbox as our mailbox to process
    imap.select('Inbox')

    # get all emails that are in inbox that have not been deleted
    imap.search(["NOT", "SEEN"]).each do |uid|
      # fetches the straight up source of the email for tmail to parse
      #source = imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822']

      message = imap.fetch(uid, "RFC822")[0].attr["RFC822"]
      message = Mail.new(message)
      handle_message(message)
      
      imap.store(uid, "+FLAGS", [:Seen])
      
      #imap.copy(uid, "[Gmail]/All Mail")
      #imap.store(uid, "+FLAGS", [:Deleted])
      #imap.uid_copy(uid, "[Gmail]/All Mail")
      #imap.uid_store(uid, "+FLAGS", [:Deleted])
    end
    
    # expunge removes the deleted emails
    imap.expunge
    imap.logout
    imap.disconnect
    
  # NoResponseError and ByResponseError happen often when imap'ing
  rescue Net::IMAP::NoResponseError => e
    # send to log file, db, or email
    puts "The following error occurred 1: #{e}"
    puts e.backtrace 
  rescue Net::IMAP::ByeResponseError => e
    # send to log file, db, or email
    puts "The following error occurred 2: #{e}"
    puts e.backtrace 
  rescue => e
    puts "The following error occurred 3: #{e}"
    puts e.backtrace 
    # send to log file, db, or email
  end
  
  # sleep for SLEEP_TIME and then do it all over again
  sleep(SLEEP_TIME)
end

# default rails environment to development
ENV['RAILS_ENV'] ||= 'development'
# require rails environment file which basically "boots" up rails for this script
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
require 'net/imap'
require 'net/http'
require 'httparty'

# amount of time to sleep after each loop below
SLEEP_TIME = 5

# mail.yml is the imap config for the email account (ie: username, host, etc.)
config = YAML.load(File.read(File.join(::Rails.root.to_s, 'config', 'mail.yml')))

# this script will continue running forever
loop do
  begin
    # make a connection to imap account
    imap = Net::IMAP.new(config['host'], config['port'], true)
    imap.login(config['username'], config['password'])
    
    # select inbox as our mailbox to process
    imap.select('Inbox')
    
    # get all emails that are in inbox that have not been deleted
    imap.uid_search(["NOT", "DELETED"]).each do |uid|
      # fetches the straight up source of the email for tmail to parse
      #source = imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822']
      
      message = imap.uid_fetch(uid, ['ENVELOPE', 'BODY[TEXT]']).first
      body = message.attr["BODY[TEXT]"]
      envelope = message.attr["ENVELOPE"]
      
      subject = envelope.subject
      project_name = envelope.to.first.mailbox
      user_email = envelope.from.first.mailbox + "@" + envelope.from.first.host
      
      if project_name != "app" then
        user = User.where(:email => user_email).first
        project = Project.where("lower(name) = ?", project_name).first
        
        if project && project.mail_callback && user then
          
          url = project.mail_callback.strip
          url = "http://" + url unless url.match(%r|^http://|)
          
          payload = {}
          payload["user"] = user.attributes
          payload["subject"] = subject
          payload["body"] = body
          
          HTTParty.post(url, :body => payload) rescue false
        end
      end
      
      # there isn't move in imap so we copy to new mailbox and then delete from inbox
      imap.uid_copy(uid, "[Gmail]/All Mail")
      imap.uid_store(uid, "+FLAGS", [:Deleted])
    end
    
    # expunge removes the deleted emails
    imap.expunge
    imap.logout
    imap.disconnect

  # NoResponseError and ByResponseError happen often when imap'ing
  rescue Net::IMAP::NoResponseError => e
    # send to log file, db, or email
    raise e
  rescue Net::IMAP::ByeResponseError => e
    # send to log file, db, or email
    raise e
  rescue => e
    raise e
    # send to log file, db, or email
  end
  
  # sleep for SLEEP_TIME and then do it all over again
  sleep(SLEEP_TIME)
end

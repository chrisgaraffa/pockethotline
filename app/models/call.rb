class Call < ActiveRecord::Base
  self.implicit_order_column = :created_at


  belongs_to :account
  belongs_to :caller
  belongs_to :operator, :class_name => 'User'
  has_one :caller_review
  has_and_belongs_to_many :sponsors
  has_many :outgoing_calls
  has_one :review
  belongs_to :category, class_name: 'Callcategory', foreign_key: 'callcategory_id'

  has_many :comments, -> { order ('created_at ASC') }

  before_create :set_token

  scope :answered, -> { where('answered_at is not ?', nil) }
  scope :unanswered, -> { where('answered_at is ?', nil) }
  scope :unsponsored, -> { joins('left outer join calls_sponsors on calls.id=calls_sponsors.call_id').where('calls_sponsors.sponsor_id is null') }
  scope :sponsored, -> { joins('left outer join calls_sponsors on calls.id=calls_sponsors.call_id').where('calls_sponsors.sponsor_id is not null') }
  scope :has_notes, -> { where('notes is not ?', nil) }

  def answered?
    answered_at.present?
  end

  def unanswered?
    answered_at.blank?
  end

  def open?
    ended_at.blank?
  end

  def finished?
    recording_duration.present? || ended_at.present?
  end

  def timecode
    begin
      hours   = (length / 3600).round
      minutes = ((length - (hours * 3600)) / 60).round
      seconds = ((length - (hours * 3600) - (minutes * 60)))

      result  = ""
      result += "#{hours}:" if hours > 0
      result += "#{minutes}:"
      result += "#{"%02d" % seconds}"
      result
    rescue
      '?'
    end
  end

  def self.create_from_twilio_params(params)
    caller = Caller.find_or_create_by(:phone => params[:Caller]) do |c|
      c.state = params[:CallerState]
      c.from_state = params[:FromState]
      c.city = params[:CallerCity]
      c.from_city = params[:FromCity]
      c.zip = params[:CallerZip]
      c.from_zip = params[:FromZip]
      c.from_phone = params[:From]
      c.country = params[:CallerCountry]
      c.from_country = params[:FromCountry]
    end

    caller.calls.create(:twilio_id  => params[:CallSid], :started_at => Time.now)
  end

  def redirect_if_not_answered(url)
    begin
      TWILIO.calls.get(self.twilio_id).redirect_to(url) if self.unanswered?
    rescue => e
      logger.info "Call could not redirect_if_not_answered: #{self.inspect} ERROR: #{e}"
    end
  end

  def notify_operators_of_hangup(url)
    outgoing_calls.each do |outgoing_call|
      begin
        c = TWILIO.calls.get(outgoing_call.twilio_id)
        c.redirect_to(url) if c.status == 'in-progress'
      rescue => e
        logger.info "Call could not notify_operators_of_hangup: #{c.inspect} ERROR: #{e}"
      end
    end
  end

  def assign_sponsors
    available_sponsors = Sponsor.successful.minutes_remain.order(:created_at)
    minutes = (length / 60)

    while (minutes > 0 && available_sponsors.any?) do
      sponsor = available_sponsors.select {|s| s.minutes_remaining > 0 }.first
      if sponsor
        minutes = minutes - sponsor.minutes_remaining
        self.sponsors << sponsor
        sponsor.update_attribute(:minutes_remaining, (minutes > 0 ? 0 : minutes.abs))
      else
        available_sponsors =[]
      end
    end
  end

  def request_caller_review
    message = "Did you get some help from the hotline? Take 2 mins and say thanks: http://#{Rails.configuration.x.hotline.domain}/c/#{token}"

    if TWILIO.sms.messages.create(
        :from => Rails.configuration.x.hotline.sms_number,
        :to => caller.phone,
        :body => message
      )
      self.update_attribute(:sms_caller_for_review_at, Time.now)
    else
      false
    end
  end

  private
  def set_token
    self.token = rand(36**8).to_s(36)
    while Call.find_by_token(self.token)
      self.token = rand(36**8).to_s(36)
    end
  end
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :confirmable, :lockable,
         :timeoutable

         #attr_accessor :password, :admin_creating_user, :user_applying, :user_updating_themselves, :skip_password_validation

  belongs_to :account
  has_many :calls, -> { order('answered_at DESC') }, :foreign_key => 'operator_id'
  has_many :status_updates, -> { order('started_at ASC') }, :dependent => :destroy
  has_many :reviews, -> { order('created_at DESC') }, :foreign_key => 'operator_id'
  has_many :oncall_schedules, -> { order('wday DESC') }
  has_many :comments, -> { order('created_at desc') }
  has_many :activities, -> { order('created_at desc') }
  
  validates_presence_of :email
  validates_presence_of :name
  validates_uniqueness_of :email
  validates_uniqueness_of :phone
  validates :phone, :phone => true, :unless => Proc.new {|u| u.phone.blank? }
  validates :phone, :presence => true
  validates :email, :presence => true, :email_format => true

  scope :on_call, -> { where(:on_call => true) }
  scope :active, -> { where(:deleted_at => nil).where(:approved => true) }
  scope :pending, -> { where(:approved => false).where(:deleted_at => nil) }
  scope :have_logged_in, -> { where('last_sign_in_at IS NOT ?', nil) } 
  scope :have_not_logged_in, -> { where(:last_sign_in_at => nil) }
  scope :admin, -> { where(:admin => true) }
  
  scope :receive_volunteers_first_availability, -> { where(:volunteers_first_availability_emails => true) }
  scope :has_phone, -> { where('phone is not ?', nil).where('phone != ?', "") }

  def active_for_authentication?
    super && approved?
  end

  def inactive_messagge
    approved? ? super : :not_approved
  end

  def total_points
    reviews.select {|c| c.award_point_to_operator? }.length
  end

  def toggle_status(status=nil)
    case status
    when :on
      go_on_call
    when :off
      go_off_call
    else
      on_call? ? go_off_call : go_on_call
    end
  end

  def notify_admins_of_volunteers_first_availability
    if on_call? && admins_notified_of_first_availability_at.blank?
      User.admin.active.receive_volunteers_first_availability.each do |admin|
        UserMailer.notify_admin_of_volunteers_first_availability(self, admin).deliver
      end
      self.update_attributes!(:admins_notified_of_first_availability_at => Time.now, :skip_password_validation => true)
    end
  end

  def go_on_call
    if status_updates.empty? || status_updates.last && status_updates.last.closed?
      status_updates.create(:started_at => Time.now)#, :account => account)
    end
    TwitterIntegration.delay({:run_at => 10.minutes.from_now}).tweet_that_operators_are_on_call if TwitterIntegration.active?
    delay({:run_at => 10.minutes.from_now}).notify_admins_of_volunteers_first_availability if admins_notified_of_first_availability_at.blank? && !self.admin?
    update_attribute(:on_call, true)
  end
  private :go_on_call

  def go_off_call
    on_call_span = status_updates.last
    if on_call_span && on_call_span.open?
      on_call_span.update(:ended_at => Time.now)
    end
    self.update_attribute(:on_call, false)
  end
  private :go_off_call

  def deactivate
    self.update_attribute(:deleted_at, Time.now)
  end

  def self.available_to_take_calls(include_those_on_call=false)
    users = User.includes(:calls).active.on_call.has_phone
    users = users.reject {|u| u.on_a_call?} unless include_those_on_call
    users
  end

  def on_a_call?
    calls.any? && calls.first.open?
  end

  def hours_on_call(start,stop)
    c = status_updates.where('started_at >= ?', start).where('started_at <= ?', stop)
    c.inject(0) { |sum, p| sum + p.length } / 3600
  end

  def length_of_calls(start,stop)
    c = calls_between(start,stop)
    c.inject(0) { |sum, p| p.length ? sum + p.length : sum } / 60
  end

  def calls_between(start,stop)
    calls.where('started_at >= ?', start).where('started_at <= ?', stop)
  end

  def jsonify(to_json=false)
    result = {}
    %w(name twitter bio on_call? on_a_call?).each do |a|
      result[a.to_sym] = self.send(a)
    end
    if to_json
      {:user => result}.to_json
    else
      result
    end
  end

  def update_oncall_status_from_schedule(status=nil, end_time=nil)
    if on_call? && status == :off || !on_call? && status == :on
      toggle_status(status)
      UserMailer.status_changed_by_schedule(self, status, end_time).deliver if self.schedule_emails?
    end
  end

  def gravatar(size='512')
    # include MD5 gem, should be part of standard ruby install
    require 'digest/md5'

    # create the md5 hash
    hash = Digest::MD5.hexdigest(email.downcase)

    image_src = "http://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end
end

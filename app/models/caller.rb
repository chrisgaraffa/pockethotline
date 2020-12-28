class Caller < ActiveRecord::Base
  belongs_to :account
  has_many :calls

  def over_caller?
    if Rails.env.development?
      false
    else
      calls.where('created_at >= ?', 30.minutes.ago).where('answered_at is null').length > 2
    end
  end
end

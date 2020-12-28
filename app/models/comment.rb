class Comment < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :call

  validates_presence_of :body
  validates :body, :unique_in_the_last_five_seconds => true

  def notify(link)
    to =  [call.user]
    to += call.comments.collect(&:user)
    to = (to - [user]).uniq
    to.each do |user|
      UserMailer.new_comment("#{user.name} <#{user.email}>", self, link).deliver
    end
  end
end

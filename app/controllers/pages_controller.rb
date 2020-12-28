class PagesController < ApplicationController
  before_action :require_login, :only => [:dashboard]
  
  def index
    @operators = User.available_to_take_calls(true)
  end

  def volunteer
  end

  def volunteers
    @operators = User.active.have_logged_in.includes(:oncall_schedules)
  end

  def dashboard
    @recentAnsweredCalls = Call.answered.includes([:comments => :user]).includes(:operator).limit(10)
    @operators = User.active
    @operators_oncall = User.active.select {|o| o.on_call?}
  end
end

class CallsController < ApplicationController
  before_action :require_login
  # before_action :require_admin

  def index
    @page_title = "Calls"

    @user = find_user
    if current_user.admin? && !@user
      @calls = Call.all
    else
      @user = current_user
      @calls = @user.calls
    end

    @calls = @calls.includes(:caller).page(params[:page])
    date = params[:date].to_date rescue nil
    @calls = @calls.where('created_at >= ? and created_at <= ?', date.beginning_of_day, date.end_of_day) if date
    @calls = @calls.order(:created_at)
  end

  def log_notes
    @call = Call.find_by_id(params[:call_id])
    if !@call.present?
      flash[:call_notes] = params[:notes]
      redirect_to dashboard_path, :alert => "That call number doesn't exist." and return
    end
    @call.notes = params[:notes]
    @call.callcategory_id = params[:callcategory_id]

    respond_to do |format|
      if @call.save
        format.html { redirect_to dashboard_path }
      else
        format.html { redirect_to dashboard_path, :alert => "The call notes could not be saved." }
      end
    end
  end

  private
  def find_user
    if params[:user_id]
      user = current_user
      if current_user.admin? && params[:user_id] != 'current'
        user = User.find(params[:user_id])
      end
      user
    end
  end
end

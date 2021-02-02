require 'bcrypt'
class UsersController < ApplicationController
  before_action :require_login, :except => [:set_password, :save_password, :apply, :apply_thanks, :create, :unsubscribe]
  before_action :require_admin, :only => [:index, :new, :destroy, :show, :approve]
  before_action :find_user, :only => [:edit, :show, :toggle_status, :edit_on_call_status, :update, :destroy, :approve]

  def index
    @page_title = "Operators"

    @users = User.order('name').active.includes(:oncall_schedules)
    @users = @users.paginate(:page => params[:page])

    @pendingUsers = User.pending
  end

  def edit
    puts "editing"
    @page_title = @user.name

    render :action => :edit
  end

  def show
    @page_title = @user.name

    render :action => :edit
  end

  def edit_on_call_status
  end

  def toggle_status
    if !@user.toggle_status
      head :bad_request
    end
  end

  def set_password
    @user = User.find_by_token(params[:token])
    unless @user
      flash.now.alert = "Invalid link"
      redirect_to root_url
    end
  end

  def save_password
    @user = User.find_by_token(params[:token])
    if @user && @user.update_attributes(params[:user].slice(:password, :password_confirmation, :phone))
      @user.reload
      login(@user)
      redirect_to dashboard_url
    else
      redirect_to set_password_url(:token => params[:token]), :notice => "Something went wrong, try again."
    end
  end

  def new
    @page_title = "New Operator"
    @user = User.new
  end

  def apply
    @user = User.new
  end

  def create
    if logged_in? && current_user.admin?
      admin_creating_users
    else
      user_applying
    end
  end

  def update
    if @user.update(user_params)
      if params[:user][:on_call] == '1'
        @user.toggle_status(:on)
      elsif params[:user][:on_call] == '0'
        @user.toggle_status(:off)
      end
      if current_user.admin?
        @user.admin = params[:user][:admin] if params[:user][:admin]
        @user.save
      end
      redirect_to edit_user_url(@user), :notice => "User updated"
    else
      render :action => "edit"
    end
  end

  def destroy
    @user.admin_creating_user = true
    @user.update_attributes!(:deleted_at => Time.now)

    redirect_to users_url, :notice => "User deleted"
  end

  def approve
    @user.update_attribute(:pending_approval, false)
    UserMailer.welcome(@user).deliver
    redirect_to edit_user_path(@user), :notice => "User approved."
  end

  def unsubscribe
    @user = User.find_by_token!(params[:token])
    update = {
      :schedule_emails => false,
      :volunteers_first_availability_emails => false
    }
    update.delete(:schedule_emails) if (params[:only] == 'newsletter' || params[:only] == 'volunteers_first_availability_emails')
    update.delete(:volunteers_first_availability_emails) if (params[:only] == 'schedule' || params[:only] == 'newsletter')
    @user.update_attributes!(update)
    redirect_to login_url, :notice => "#{@user.email} has been unsubscribed from #{params[:only] ? params[:only].humanize.downcase : 'all emails'}. To change this login and go to 'My Info'."
  end

  private
  def find_user
    @user = User.find(params[:id])
  end

  def admin_creating_users
    @user = User.new(params[:user].slice(:name, :email))
    @user.admin_creating_user = true

    if @user.save
      UserMailer.welcome(@user).deliver
      redirect_to("Invite email sent to #{@user.email}", :notice => notice)
    else
      render :action => "new"
    end
  end

  def user_applying
    puts params
    @user = User.new(user_params)
    @user.pending_approval = true
    @user.user_applying = true

    if @user.save
      UserMailer.user_applied(@user).deliver
      redirect_to(apply_thanks_users_url)
    else
      render :action => "apply"
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :twitter, :bio, :schedule_emails, :volunteers_first_availability_emails)
  end
end

class SessionsController < ApplicationController
  before_action :redirect_if_authenticated, only: [:create, :new]
  before_action :authenticate_user!, only: [:destroy]

  def create
    @user = User.authenticate_by(email: params[:user][:email].downcase, password: params[:user][:password])
    if @user
      if @user.unconfirmed?
        redirect_to new_confirmation_path, alert: "Incorrect email or password."
      else
        after_login_path = session[:user_return_to] || root_path
        login @user
        remember(@user) if params[:user][:remember_me] == "1"
        redirect_to after_login_path, notice: "Signed in."
        active_session = login @user
        remember(active_session) if params[:user][:remember_me] == "1"
      end
    else
      flash.now[:alert] = "Incorrect email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def self.authenticate_by(attributes)
    passwords, identifiers = attributes.to_h.partition do |name, value|
      !has_attribute?(name) && has_attribute?("#{name}_digest")
    end.map(&:to_h)

    raise ArgumentError, "One or more password arguments are required" if passwords.empty?
    raise ArgumentError, "One or more finder arguments are required" if identifiers.empty?
    if (record = find_by(identifiers))
      record if passwords.count { |name, value| record.public_send(:"authenticate_#{name}", value) } == passwords.size
    else
      new(passwords)
      nil
    end
  end

  def destroy
    if current_user
      logout
    else 
      forget_active_session
    end
    redirect_to root_path, notice: "Signed out."
  end

  def new
  end

  def destroy_all
    forget_active_session
    current_user.active_sessions.destroy_all
  end

end
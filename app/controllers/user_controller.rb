# encoding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :update, :destroy]
  before_filter :update_user_form, :only => [:edit, :update, :destroy]
  before_filter :build_user, :only => [:new, :create]

  # GET /user/new
  def new
    respond_to do |format|
      format.html { render layout: "nonavigation"}
      format.json { render json: @user }
    end
  end

  # GET /user/edit
  def edit
    # do nothing
  end

  # POST /user
  # POST /user.json
  def create
    respond_to do |format|
      if @user.save
        sign_in @user
        format.html { redirect_to weight_logs_path }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new", layout: "nonavigation" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user
  # PUT /user.json
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to weight_logs_path }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user
  def destroy
    @user.destroy
    sign_out

    redirect_to login_path
  end
  
  private
  def update_user_form
    @user = User.find(current_user.id)
  end
  
  def build_user
    @user = User.new(params[:user])
  end
end

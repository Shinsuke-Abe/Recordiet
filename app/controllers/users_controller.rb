# encoding: utf-8
class UsersController < ApplicationController
  before_filter :required_login, :only => [:edit, :update, :destroy]
  
  # GET /user
  def show
    @user = User.find(session[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /user/new
  def new
    @user = User.new

    respond_to do |format|
      format.html { render layout: "nonavigation"}
      format.json { render json: @user }
    end
  end

  # GET /user/edit
  def edit
    @user = User.find(session[:id])
  end

  # POST /user
  # POST /user.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        session[:id] = @user.id
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
    @user = User.find(session[:id])

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
    @user = User.find(session[:id])
    @user.destroy

    redirect_to login_path
  end
end

class UsersController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,    only: [:edit, :update] 
  before_filter :admin_user,      only: :destroy
  before_filter :logged_in,       only: [:new, :create]

  	def new
        @user = User.new
  	end

  	def show
  		@user = User.find(params[:id])
  	end

	def create
  		@user = User.new(params[:user])
  		if @user.save
  			sign_in @user
  			flash[:success] = "Welcome to the Sample App!"
  			redirect_to @user
		else
			render 'new'
		end
	end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
        sign_in @user
        flash[:success] = "Profile updated"
        redirect_to @user
    else
      render 'edit'
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    if User.find(params[:id]).admin?  
      redirect_to root_path
    else
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
      redirect_to users_url
    end
  end

  private

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def logged_in
      if signed_in?
        redirect_to root_path
      end
    end

end

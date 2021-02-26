class UsersController < Base
  before_action :require_login, except: %i[new create]
  before_action :logged_in_user_can_not_access_sign_up, only: %i[new create]
  before_action :correct_user, only: %i[edit update]

  def new
    @user = User.new
  end

  def index
    @users = User.includes(:wordnotes).page(params[:page]).order(email: :asc)
  end

  def show
    @user = User.find(params[:id])
    @wordnotes = User.find(params[:id]).wordnotes.includes(:user, :tangos, :favorites, :tango_configs)
    @tango = @user.wordnotes.build.tangos.build
    @favorite_wordnotes = @user.favorite_wordnotes.includes(:user, :tangos)
  end

  def create
    @user = User.new(user_params)
    @user.email = @user.email.downcase
    if @user.authenticate(@user.password) && @user.save 
      session[:user_id] = @user.id
      flash[:success] = 'ユーザーを登録しました'
      redirect_to :root
    else
      flash.now[:danger] = @user.errors.messages.to_a.join('')
      render action: 'new'
    end
  end

  def update
    @user = current_user
    @user.assign_attributes(user_params)
    if @user.save
      flash[:success] = '登録情報を更新しました'
      redirect_to user_path(@user)
    else
      flash.now[:danger] = @user.errors.messages.to_a.join('')
      render action: 'edit'
    end
  end

  def edit
    @user = @current_user
  end

  def destroy
    @user = User.find(params[:id])
    flash[:success] = "#{@user.name}:ユーザーを削除しました"
    @user.destroy!
    redirect_to :root
  end

  def search
    search_word = params[:search_word]
    @users = nil
    if search_word.strip == ''
      @users = User.all.eager_load(:wordnotes)
    else
      @users = User.left_outer_joins(:wordnotes).where('wordnotes.subject like ?', "%#{search_word}%").or(User.left_outer_joins(:wordnotes).where('users.name like ?', "%#{search_word}%")).distinct
    end
    @users = @users.page(params[:page]).order(updated_at: :desc)
    render 'users/index'
  end
   
  private

    def user_params
      params.require(:user).permit(
        :name, :email, :password, :password_confirmation,
        :suspended, :profile, :profile_image
      )
    end

    def correct_user
      if @current_user != User.find_by(id: params[:id]) && @current_user.admin? != true
        flash[:danger] = 'アクセス権がありません'
        redirect_to :root
      end
    end

    def logged_in_user_can_not_access_sign_up
      redirect_to :root if @current_user
    end
end

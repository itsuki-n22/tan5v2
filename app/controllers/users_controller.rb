class UsersController < Base
  before_action :current_user
  before_action :logged_in?
  before_action :correct_user, only: %i[edit update destroy]
  before_action :authorize, only: %i[new create]

  def new
    @user = User.new
  end

  def index
    @users = User.includes(:wordnotes).page(params[:page]).order(email: :asc)
  end

  def show
    p "-----------------------"
    p params
    @user = User.find(params[:id])
    @wordnotes = User.find(params[:id]).wordnotes.includes(:user, :tangos).order(updated_at: :asc)
    @tango = @user.wordnotes.build.tangos.build
    @favorite_wordnotes = @user.favorite_wordnotes.includes(:user, :tangos)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'ユーザーを登録しました'
      redirect_to :root
    else
      flash.now[:danger] = @user.errors.messages.to_a.join('')
      render action: 'new'
    end
  end

  def update
    @user = current_user
    @user = User.find_by(id: params[:id]) if @current_user.admin?
    @user.assign_attributes(user_params)
    if @user.save
      flash[:success] = '登録情報を更新しました'
      redirect_to user_path(@user)
    else
      flash.now[:danger] = @user.errors.messages.to_a.join('')
      render action: 'new'
      p @user.errors
    end
  end

  def edit
    @user = @current_user
    @user = User.find(params[:id]) if @current_user.admin?
  end

  def destroy
    @user = User.find(params[:id])
    flash[:success] = "#{@user.name}:ユーザーを削除しました"
    @user.destroy!
    redirect_to :root
  end

  def suspend
    @user = User.find_by(id: params[:id])
    status = (@user.suspended? ? false : true)
    if @user.update_column(:suspended, status)
      flash[:success] = "#{@user.name}:状態を変更しました"
      redirect_to :root
    end
  end

  def search
    search_word = params[:search_word]
    @users = nil
    if search_word.strip == ''
      @users = User.all.eager_load(:wordnotes)
    else
      @users = User.left_outer_joins(:wordnotes).where('wordnotes.subject like ?', "%#{search_word}%").or(User.left_outer_joins(:wordnotes).where('users.name like ?', "%#{search_word}%")).distinct
      # @users = User.where('users.name like ?', "%#{search_word}%")
    end
    @users = @users.page(params[:page]).order(updated_at: :desc)
    render 'users/index'
  end

  private def user_params
    params.require(:user).permit(
      :email, :password, :name,
      :suspended, :profile, :profile_image
    )
  end

  private def correct_user
    if @current_user != User.find_by(id: params[:id]) && @current_user.admin? != true
      flash[:danger] = 'アクセス権がありません'
      redirect_to :root
    end
  end
  private def authorize
    unless @current_user.admin?
      flash[:danger] = '管理者としてアクセス権がありません'
      redirect_to :root
    end
  end
  private def logged_in?
    redirect_to :root if @current_user.nil?
  end
end

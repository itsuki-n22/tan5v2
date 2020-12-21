class SessionsController < Base
  def new
    if current_user
      redirect_to :root
    else
      @form = LoginForm.new
      render action: 'new'
    end
  end

  def create
    @form = LoginForm.new(login_form_params)
    user = User.find_by('LOWER(email) = ?', @form.email.downcase) if @form.email.present?
    @save = false
    if user.authenticate(@form.password) #Authenticator.new(user).authenticate(@form.password)
      session[:user_id] = user.id
      @save = true
      flash[:success] = 'ログイン成功'
      redirect_to :root
    else
      flash[:danger] = 'パスワードかメールアドレスのいずれかが間違っています。'
      render action: :new
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:success] = 'ログアウトしました'
    redirect_to :root
  end

  private def login_form_params
    params.require(:login_form).permit(:email, :password)
  end
end

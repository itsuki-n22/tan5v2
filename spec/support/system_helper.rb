module SystemHelper
  
  def login_as(user)
    visit login_path
    password = 'password'
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: password
    click_button 'ログイン'
    sleep 1
  end

end

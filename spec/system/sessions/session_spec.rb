RSpec.describe 'session', type: :system, js: true do
  let(:user) { create(:user) }

  describe 'ログイン' do
    context '認証情報が正しい場合' do
      example 'ログインに成功すること' do
        visit login_path
        password = 'password'
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: password
        click_button 'ログイン'
        expect(page).to have_content 'ログイン成功'
        expect(current_path).to eq user_path(user)
      end
    end

    context '認証情報が正しくない場合' do
      example 'ログインに失敗すること' do
        visit login_path
        password = 'passwordoo'
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: password
        click_button 'ログイン'
        expect(page).to have_content 'パスワードかメールアドレスのいずれかが間違っています。'
        expect(current_path).to eq login_path
      end
    end
  end

  describe 'ログアウト' do
    before do
      login_as(user)
    end
    example 'ログアウトできること' do
      find(:id, 'navbarDropdown').click
      sleep 1
      click_link 'ログアウト'
      expect(page).to have_current_path root_path, ignore_query: true
    end
  end
end

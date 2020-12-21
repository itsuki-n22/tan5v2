describe 'User', type: :system, js: true do

  describe 'ユーザー新規登録画面' do
    before { visit new_user_path }

    example 'ユーザーが登録できること', point: true do
      fill_in 'user_email', with: 'xx@xx.xx'
      fill_in 'user_name', with: 'abc'
      fill_in 'user_profile', with: 'def'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user_profile_image', Rails.root.join('spec','fixtures', 'fixture.jpg')
      click_button '登録'
      expect(page).to have_content 'ユーザーを登録しました'
    end

    example 'パスワードとパスワード確認が一致しない場合,更新できないこと', point: true do
      fill_in 'user_email', with: 'xx@xx.xx'
      fill_in 'user_name', with: 'abc'
      fill_in 'user_profile', with: 'def'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password1'
      click_button '登録'
      expect(page).not_to have_content 'ユーザーを登録しました'
    end
   
  end

  describe 'ユーザー登録情報変更画面' do
    let(:user) { create(:user) }
    before { login_as(@user = user) }
    
    example 'フォームに初期値が正しく設定されていること' do
      visit edit_user_path @user
      expect(find(:id , 'user_email').value).to eq @user.email
      expect(find(:id , 'user_name').value).to eq @user.name
      expect(find(:id , 'user_profile').value).to eq @user.profile
      expect(find(:id , 'profile-image-preview')[:src]).to include 'no_image.png'
    end

    example 'ユーザー情報を更新できること', point: true do
      visit edit_user_path @user
      fill_in 'user_email', with: 'xx@xx.xx'
      fill_in 'user_name', with: 'abc'
      fill_in 'user_profile', with: 'def'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user_profile_image', Rails.root.join('spec','fixtures', 'fixture.jpg')
      click_button '登録'
      expect(page).to have_content '登録情報を更新しました'
      visit edit_user_path @user
      expect(find(:id , 'user_email').value).to eq 'xx@xx.xx'
      expect(find(:id , 'user_name').value).to eq 'abc'
      expect(find(:id , 'user_profile').value).to eq 'def'
      expect(find(:id , 'profile-image-preview')[:src]).to include 'profile.jpg'
    end

    example 'パスワードが一致しない場合,更新できないこと', point: true do
      visit edit_user_path @user
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password1'
      click_button '登録'
      expect(page).not_to have_content '登録情報を更新しました'
    end

    example '画像をアップロードした場合、プレビュー表示の画像が変更されること' do
      visit edit_user_path @user
      attach_file 'user_profile_image', Rails.root.join('spec','fixtures', 'fixture.jpg')
      expect(find(:id , 'profile-image-preview')[:src]).not_to include 'no_image.png'
    end
  end

end

require 'rails_helper'
describe 'User', type: :system, js: true do

  describe 'ユーザー一覧/検索画面' do

    let!(:user) { create(:user, name: "test1") }
    let!(:user2) { create(:user, name: "test2") }
    before do 
      8.times{ create(:user) } 
      login_as(user)
    end
    
    example 'ユーザーがすべて表示されること' do
      within '#navbarSupportedContent' do
        find(:xpath, "//*[contains(@class, 'btn-outline-success')]").click
      end
      expect(all(:xpath, "//*[contains(@id, 'user-no-')]").size).to eq(10)
    end

    example '文字列を含むユーザーのみが表示されること' do
      within '#navbarSupportedContent' do
        fill_in 'search_word', with: 'test'
        find(:xpath, "//*[contains(@class, 'btn-outline-success')]").click
      end
      expect(all(:xpath, "//*[contains(@id, 'user-no-')]").size).to eq(2)
    end
      
  end

  describe 'users/show' do
    context 'はじめてのログイン' do

      let!(:user) { create(:user) }
      before { login_as(user) }

      example '初期画面が正しく表示されていること' do
        expect(page).not_to have_content '単語を登録'
        expect(page).to have_content '単語帳を作成'
        expect(page).to have_content 'アカウント情報変更'
        expect(find(:xpath, '//*[@class="user-name"]/h1').text).to have_content user.name
        expect(find(:xpath, '//*[@class="user-profile"]').text).to have_content user.profile
        expect(find(:xpath, '//*[@class="user-created_at"]').text).to have_content user.created_at.to_s.split(' ').first
      end

      example '単語帳を登録できること' do
        find(:id, 'build-wordnote-btn').click
        find(:id, 'wordnote_name').send_keys 'sample'
        fill_in 'wordnote_subject', with: 'English'
        click_button '単語帳を作成'
        expect(page).to have_content 'sample'
        expect(page).to have_content 'English'
        expect(page).to have_content '単語を登録'
      end

      example '単語を登録できること' do
        FactoryBot.create(:wordnote, user: user)
        visit current_path
        find(:id, 'add-tango-btn').click
        within '#tango_register' do
          fill_in 'tango_question', with: 'a'
          fill_in 'tango_answer', with: 'b'
          click_button '単語を登録'
          find(:xpath, '//*[@class="btn btn-outline-info modal-close close-btn"]').click
        end
        sleep 1
        tmp = find(id: 'created-wordnotes')
        expect(tmp).to have_content('問題数: 1')
      end
    end

    context '自分のユーザーページ' do

      let!(:user) { create(:user) }
      let!(:other_user) { create(:user) }
      let!(:other_wn1) { create(:wordnote, user: other_user) }
      let!(:other_wn2) { create(:wordnote, user: other_user) }
      let!(:my_not_open_wn) { create(:wordnote, user: user, is_open: false) }
      let!(:my_wn1) { create(:wordnote, user: user) }
      let!(:my_wn2) { create(:wordnote, user: user) }
      let!(:favorite1) { user.favorite.create(wordnote_id: other_wn1.id) }
      let!(:favorite2) { user.favorite.create(wordnote_id: my_wn1.id) }

      before { login_as(user) }

      example 'お気に入りの単語帳や作成した単語帳が適切に表示されていること' do
        ##### 非公開の単語帳も自分のページだと表示される
        expect(page).to have_css "#wordnote-no-#{my_not_open_wn.id}"
        ##### 自分の単語帳でも他人の単語帳でもお気に入りの単語帳が表示される
        within '.favorites-list' do
          expect(page).to have_css "#wordnote-no-#{my_wn1.id}"
          expect(page).to have_css "#wordnote-no-#{other_wn1.id}"
        end
        ##### 自分の作成した単語帳が「作成した単語帳」に表示される
        within "#created-wordnotes" do 
          expect(page).to have_css "#wordnote-no-#{my_wn1.id}"
          expect(page).to have_css "#wordnote-no-#{my_wn2.id}"
        end
      end

      example '情報を変更するリンクやボタンが表示がされていること' do
        #単語帳の編集ボタン"
        expect(page).to have_css "#edit-no-#{my_wn2.id}"
        expect(page).to have_css "#edit-no-#{my_wn1.id}"
        #お気に入りの削除ボタン"
        expect(page).to have_css "#favorite-delete-no-#{other_wn1.id}"
        expect(page).to have_css "#favorite-delete-no-#{my_wn1.id}"
      end

      example '単語帳をお気に入りに追加できること' do
        within "#wordnote-no-#{my_wn2.id}" do
          expect {
            find(:id, "favorite-no-#{my_wn2.id}").click
            expect(page).to have_css '.favorited'
          }.to change(Favorite.all, :count).by(1)
        end
      end

      example '単語帳をお気に入りから削除できること' do
        within "#created-wordnotes #wordnote-no-#{my_wn1.id}" do
          expect {
            find(:id, "favorite-no-#{my_wn1.id}").click
            expect(page).not_to have_css '.favorited'
          }.to change(Favorite.all, :count).by(-1)
        end
      end

      example '単語帳のリンクから作成ユーザーのページに移動できること' do
        within "#wordnote-no-#{other_wn1.id}" do
          click_link other_wn1.user.name
          expect(current_path).to eq user_path(other_user)
        end
      end

      example '単語帳名をクリックしても単語が0ならページを移動しないこと' do
        within "#wordnote-no-#{other_wn1.id}" do
          click_link other_wn1.name
          expect(current_path).to eq user_path(user)
        end
      end

      example '単語帳名をクリックして当該の単語帳ページへ移動できること' do
        FactoryBot.create(:tango, wordnote: my_wn1)
        within "#created-wordnotes #wordnote-no-#{my_wn1.id}" do
          click_link my_wn1.name
          expect(current_path).to eq user_wordnote_path(user_id: my_wn1.user_id, id: my_wn1.id)
        end
      end
    end

    context '他人のユーザーページ' do
      let!(:user) { create(:user) }
      let!(:other_user) { create(:user) }
      let!(:other_wn1) { create(:wordnote, user: other_user) }
      let!(:other_wn2) { create(:wordnote, user: other_user) }
      let!(:other_not_open_wn) { create(:wordnote, user: other_user, is_open: false) }
      let!(:my_wn) { create(:wordnote, user: user) }

      before do
        other_user.favorite.create(wordnote_id: other_wn1.id)
        user.favorite.create(wordnote_id: other_wn1.id)
        other_user.favorite.create(wordnote_id: my_wn.id)
        login_as(user)
        visit user_path other_user
      end

      example 'お気に入りの単語帳や作成した単語帳が適切に表示されていること' do
        ##### 非公開の単語帳が表示されない
        expect(page).not_to have_css "#wordnote-no-#{other_not_open_wn.id}"
        ##### 自分の単語帳でも他人の単語帳でもお気に入りの単語帳が表示される
        within '.favorites-list' do
          expect(page).to have_css "#wordnote-no-#{my_wn.id}"
          expect(page).to have_css "#wordnote-no-#{other_wn1.id}"
        end
        ##### 他ユーザーの作成した単語帳が「作成した単語帳」に表示される
        within "#created-wordnotes" do 
          expect(page).to have_css "#wordnote-no-#{other_wn1.id}"
          expect(page).to have_css "#wordnote-no-#{other_wn2.id}"
        end
      end

      example '情報を変更するリンクやボタンが表示がされていないこと' do
        expect(page).not_to have_css "#edit-no-#{my_wn.id}"
        expect(page).not_to have_css "#edit-no-#{other_wn1.id}"
        expect(page).not_to have_css "#favorite-delete-no-#{other_wn1.id}"
        expect(page).not_to have_content 'アカウント情報変更'
        expect(page).not_to have_content '単語を登録'
        expect(page).not_to have_content '単語帳を作成'
      end

      example 'お気に入りの単語帳/ユーザーが登録した単語帳が表示されていること' do
        expect(page).not_to have_content 'アカウント情報変更'
        expect(page).not_to have_content '単語を登録'
        expect(page).not_to have_content '単語帳を作成'
      end

      example '単語帳をお気に入りに追加できること' do
        within "#wordnote-no-#{other_wn2.id}" do
          expect {
            find(:id, "favorite-no-#{other_wn2.id}").click
            expect(page).to have_css '.favorited'
          }.to change(Favorite.all, :count).by(1)
        end
      end

      example '単語帳をお気に入りから削除できること' do
        within "#created-wordnotes #wordnote-no-#{other_wn1.id}" do
          expect {
            find(:id, "favorite-no-#{other_wn1.id}").click
            expect(page).not_to have_css '.favorited'
          }.to change(Favorite.all, :count).by(-1)
        end
      end

      example '単語帳のリンクから作成ユーザーのページに移動できること' do
        within "#created-wordnotes #wordnote-no-#{other_wn1.id}" do
          click_link other_wn1.user.name
          expect(current_path).to eq user_path(other_wn1.user)
        end
      end

      example '単語帳名をクリックしても単語が0ならページを移動しないこと' do
        within "#created-wordnotes #wordnote-no-#{other_wn1.id}" do
          click_link other_wn1.name
          expect(current_path).to eq user_path(other_user)
        end
      end

      example '単語帳名をクリックして当該の単語帳ページへ移動できること' do
        FactoryBot.create(:tango, wordnote: other_wn1)
        within "#created-wordnotes #wordnote-no-#{other_wn1.id}" do
          click_link other_wn1.name
          expect(current_path).to eq user_wordnote_path(user_id: other_wn1.user_id, id: other_wn1.id)
        end
      end
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

    example 'ユーザー情報を更新できること' do
      visit edit_user_path @user
      fill_in 'user_email', with: 'xx@xx.xx'
      fill_in 'user_name', with: 'abc'
      fill_in 'user_profile', with: 'def'
      fill_in 'user_password', with: 'password'
      attach_file 'user_profile_image', Rails.root.join('spec','fixtures', 'fixture.jpg')
      click_button '登録'
      expect(page).to have_content '登録情報を更新しました'
      visit edit_user_path @user
      expect(find(:id , 'user_email').value).to eq 'xx@xx.xx'
      expect(find(:id , 'user_name').value).to eq 'abc'
      expect(find(:id , 'user_profile').value).to eq 'def'
      expect(find(:id , 'profile-image-preview')[:src]).to include 'profile.jpg'
    end

    example 'パスワードが間違っている場合登録できないこと' do
      visit edit_user_path @user
      find(:id , 'user_password').send_keys 'hoge'
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

describe 'User', type: :system, js: true do

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

      example '単語帳を登録できること', point: true do
        find(:id, 'build-wordnote-btn').click
        find(:id, 'wordnote_name').send_keys 'sample'
        fill_in 'wordnote_subject', with: 'English'
        click_button '単語帳を作成'
        sleep 1 #これを入れないと不安定
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
      let!(:my_wn1) { create(:wordnote, user: user) }
      let(:my_wn2) { create(:wordnote, user: user) }
      let(:my_not_open_wn) { create(:wordnote, user: user, is_open: false) }
      let!(:other_user) { create(:user) }
      let!(:other_wn1) { create(:wordnote, user: other_user) }
      let(:other_wn2) { create(:wordnote, user: other_user) }
      let(:favorite_my_wn1) { user.favorites.create(wordnote_id: my_wn1.id) }
      let(:favorite_other_wn1) { user.favorites.create(wordnote_id: other_wn1.id) }
      let(:tango_of_my_wn1) { create(:tango, wordnote_id: my_wn1.id) }

      before { login_as(user) }
 
      def add_condition(*x)
        visit current_path
      end
      
      example 'お気に入りの単語帳や作成した単語帳が適切に表示されていること' do
        add_condition(my_not_open_wn, my_wn2, favorite_my_wn1, favorite_other_wn1)
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
        add_condition(my_wn2, favorite_my_wn1, favorite_other_wn1)
        #単語帳の編集ボタン"
        expect(page).to have_css "#edit-no-#{my_wn2.id}"
        expect(page).to have_css "#edit-no-#{my_wn1.id}"
        #お気に入りの削除ボタン"
        expect(page).to have_css ".fav_zone-#{other_wn1.id}"
        expect(page).to have_css ".fav_zone-#{my_wn1.id}"
      end

      example '単語帳をお気に入りに追加できること' do
        within "#wordnote-no-#{my_wn1.id}" do
          expect {
            find(:xpath, "//*[contains(@class, 'fav_zone-#{my_wn1.id}')]").click
            expect(page).to have_css '.favorited'
          }.to change(Favorite.all, :count).by(1)
        end
      end

      example '単語帳をお気に入りから削除できること' do
        add_condition(favorite_my_wn1)
        within "#created-wordnotes #wordnote-no-#{my_wn1.id}" do
          expect {
            find(:xpath, "//*[@id='created-wordnotes']//*[contains(@class, 'fav_zone-#{my_wn1.id}')]").click
            sleep 1
            expect(page).not_to have_css '.favorited'
          }.to change(Favorite.all, :count).by(-1)
        end
      end

      example '単語帳のリンクから作成ユーザーのページに移動できること' do
        add_condition(favorite_other_wn1)
        within "#wordnote-no-#{other_wn1.id}" do
          click_link other_wn1.user.name
          expect(current_path).to eq user_path(other_user)
        end
      end

      example '単語帳名をクリックしても単語が0ならページを移動しないこと' do
        within "#wordnote-no-#{my_wn1.id}" do
          click_link my_wn1.name
          expect(current_path).to eq user_path(user)
        end
      end

      example '単語帳名をクリックして当該の単語帳ページへ移動できること' do
        add_condition(tango_of_my_wn1)
        within "#created-wordnotes #wordnote-no-#{my_wn1.id}" do
          click_link my_wn1.name
          expect(current_path).to eq wordnote_path(id: my_wn1.id)
        end
      end
     
      context '単語帳の編集ボタン' do
        before { find(:id, "edit-no-#{my_wn1.id}").click }

        example '名前と科目の変更が反映されること' do
          fill_in 'name', with: 'renamed-name'
          fill_in 'subject', with: 'renamed-subject'
          find(:xpath, "//*[contains(@class, 'close-btn')]").click
          sleep 1
          expect(page).to have_content('renamed-name')
          expect(page).to have_content('renamed-subject')
        end

        example '公開非公開の変更が反映されること' do
          find('#is_open').click
          find(:xpath, "//*[contains(@class, 'close-btn')]").click
          expect(Wordnote.find(my_wn1.id).is_open).to eq(false)
        end

        context '詳細設定' do
          before { find('#wordnote-detail-show-btn').click }
          
          xexample 'CSVのダウンロードが成功すること' do
            ###　ダウンロードが機能していない？
            tango_of_my_wn1
            find(:xpath, "//*[contains(text(), 'CSV ダウンロード')]").click
            expect(download_content).to include("id,question,answer,hint")
          end

          example 'CSVのアップロードにより単語データが登録されること' do
            attach_file 'csv_file', Rails.root.join('spec', 'fixtures', 'tangos_csv.csv')
            find(:xpath, "//*[contains(text(), 'CSV アップロード')]").click
            find(:xpath, "//*[contains(@class, 'close-btn')]").click
            sleep 1
            within "#created-wordnotes #wordnote-no-#{my_wn1.id}" do
              click_link my_wn1.name
              expect(current_path).to eq wordnote_path(id: my_wn1.id)
            end
          end

          example '単語帳の削除ができること' do
            find('#wordnote-delete-btn').click
            expect{
              page.driver.browser.switch_to.alert.accept
              sleep 1
            }.to change( Wordnote.all, :count).by(-1)
          end
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
        other_user.favorites.create(wordnote_id: other_wn1.id)
        user.favorites.create(wordnote_id: other_wn1.id)
        other_user.favorites.create(wordnote_id: my_wn.id)
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
            find(:xpath, "//*[contains(@class, 'fav_zone-#{other_wn2.id}')]").click
            expect(page).to have_css '.favorited'
          }.to change(Favorite.all, :count).by(1)
        end
      end

      example '単語帳をお気に入りから削除できること' do
        within "#created-wordnotes #wordnote-no-#{other_wn1.id}" do
          expect {
            find(:xpath, "//*[contains(@class, 'fav_zone-#{other_wn1.id}')]").click
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
          expect(current_path).to eq wordnote_path(id: other_wn1.id)
        end
      end
    end
  end

end

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

    example '文字列を含むユーザーのみが表示されること', check: true do
      within '#navbarSupportedContent' do
        fill_in 'q_search_word', with: 'test'
        find(:xpath, "//*[contains(@class, 'btn-outline-success')]").click
      end
      expect(all(:xpath, "//*[contains(@id, 'user-no-')]").size).to eq(2)
    end
  end
end

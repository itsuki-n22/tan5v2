describe 'Wordnote', type: :system, js: true do
  describe '他人の単語帳' do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:other_wn) { create(:wordnote, user: other_user) }
    let!(:tango) { create(:tango, wordnote: other_wn) }

    before do 
      login_as(user)
    end

    example '他人の非公開設定の単語帳にアクセスできないこと' do
      other_wn.update(is_open: false)
      visit wordnote_path(user_id: other_user, id: other_wn)
      expect(page).not_to have_content(tango.question)
    end
   
    example '他人の単語帳では単語一覧が表示できないこと' do
      visit wordnote_path(user_id: other_user, id: other_wn)
      expect( find('#show-tangos') ).not_to have_content('問題を全て見る')
    end
  end

  describe '自分の単語帳' do

    let!(:user) { create(:user) }
    let!(:my_wn) { create(:wordnote, user: user, is_open: false) }
    let!(:tangos) { create_list(:tango, 3, wordnote: my_wn) }

    before do 
      login_as(user)
      visit wordnote_path(user_id: user, id: my_wn)
    end

    example '自分のの非公開設定の単語帳にアクセスできること' do
      expect(page).to have_content(tangos.first.question)
    end

    describe '単語帳学習画面の基本動作' do
   
      example '問題と答えの表示動作が正常に機能すること' do
        ( tangos << create_list(:tango, 10, wordnote: my_wn) ).flatten!
        visit current_path
        # 画面をクリックすることで答えの表示
        find('#learn-wrapper').click
        expect(page).to have_content(tangos.first.answer)
        # 画面をクリックすることで次の問題の表示
        find('#learn-wrapper').click
        expect(page).to have_content(tangos[1].question)
        # 問題番号/総問題数　の表示が正常である
        expect( find('#tango-number') ).to have_content("2 / #{tangos.size}")
        # ＜ボタンで1つ前の問題に戻る
        find(:xpath, '//*[@id="learn-operation"]/div[2]/div[2]').click
        expect(page).to have_content(tangos[0].question)
        # ＞ボタンで1つ次の問題に移動する
        find(:xpath, '//*[@id="learn-operation"]/div[2]/div[4]').click
        expect(page).to have_content(tangos[1].question)
        # >>ボタンで9つ次の問題に移動する
        find(:xpath, '//*[@id="learn-operation"]/div[2]/div[5]').click
        expect(page).to have_content(tangos[11].question)
        # <<ボタンで9つ前の問題に戻る
        find(:xpath, '//*[@id="learn-operation"]/div[2]/div[1]').click
        expect(page).to have_content(tangos[1].question)
      end

      example '単語一覧表示ON/OFFが機能すること' do
        find('#show-tangos').click
        expect(page).to have_content(tangos[0].answer)
        expect(page).to have_content(tangos[1].question)
        expect(page).to have_content(tangos[2].hint)
        find('#show-tangos').click
        expect(page).not_to have_content(tangos[0].answer)
        expect(page).not_to have_content(tangos[1].question)
        expect(page).not_to have_content(tangos[2].hint)
      end

      example '一覧表示画面から単語の編集ができること' do
        find('#show-tangos').click
        within "#tango-no-#{tangos.first.id}" do
          find(".question").hover
          find(:xpath, "//*[contains(@class, 'fa-edit')]").click
          find("textarea").set("hoge")
          find("form").click
        end
        visit current_path
        expect(page).to have_content("hoge")
      end

      example '一覧表示画面から単語の新規登録がができること' do
        find('#show-tangos').click
        find(:xpath, '//*[@id="create-new-tango"]/td[1]/button').click
        find(:xpath, '//*[@id="create-new-tango"]/td[@class="question"]/textarea').set("hoge")
        find(:xpath, '//*[@id="create-new-tango"]/td[@class="answer"]/textarea').set("fuga")
        find(:xpath, '//*[@id="create-new-tango"]/td[@class="hint"]/textarea').set("moge")
        find(:xpath, '//*[@id="create-new-tango"]/td[6]/form').click
        visit current_path
        find('#show-tangos').click
        expect(page).to have_content("hoge")
        expect(page).to have_content("fuga")
        expect(page).to have_content("moge")
      end

      example '一覧表示画面から複数の単語を削除できること' do
        find('#show-tangos').click
        expect{ 
          2.times do |num|
            find(:id, "delete-check-#{tangos[num].id}").click
          end
          find('#delete-btn').click 
          sleep 1
        }.to change(Tango.all, :count).by(-2)
        expect{ 
          find(:xpath, '//*[@class="delete-check-all"]').click
          find('#delete-btn').click 
          sleep 1
        }.to change(Tango.all, :count).by(-1)
        expect(current_path).to eq(user_path(user))
      end
     
      example 'ヒントモーダルが正常に起動すること' do
        find('#hint-btn').click
        expect(page).to have_content('閉じる')
        expect(page).to have_content(tangos.first.hint)
        find(:xpath, "//*[contains(text(), '閉じる')]").click
        expect(page).not_to have_content('閉じる')
      end

      example '星の数による単語の絞り込みが機能していること' do
        expect{ 
          execute_script('$("#star-3").trigger("click")') # id="star-3" を持つ要素にhoverとclickの2つのイベントがあるとclickのイベントが機能しない。
          find(:xpath, '//*[@id="learn-operation"]/div[2]/div[4]').click
        }.to change( TangoDatum.all, :count ).by(1)
        expect{ 
          execute_script('$("#star-4").trigger("click")')
          find(:xpath, '//*[@id="learn-operation"]/div[2]/div[2]').click
        }.to change( TangoDatum.all, :count ).by(1)
        find(:id, "config-no-#{my_wn.id}").click
        find(:id, 'filter').find("option[value='3']").select_option
        find(:xpath, "//*[contains(@class, 'close-btn')]").click
        expect( find('#tango-number') ).to have_content("1 / 2")
      end

      example '自動再生ボタンが正常に機能していること' do
        find(:id, 'auto-btn').click
        sleep 2
        expect(page).to have_content("#{tangos.first.answer}")
        sleep 2
        expect(page).to have_content("#{tangos[1].question}")
        find(:id, 'auto-btn').click
        find(:id, "config-no-#{my_wn.id}").click
        find(:id, 'timer').find("option[value='5']").select_option
        find(:xpath, "//*[contains(@class, 'close-btn')]").click
        find(:id, 'auto-btn').click
        sleep 2
        expect(page).to have_content("#{tangos.first.question}")
        expect(page).not_to have_content("#{tangos.first.answer}")
        sleep 3
        expect(page).to have_content("#{tangos.first.answer}")
      end

      example '前回の途中から表示する機能が正常に動いていること' do
        expect(page).to have_content(tangos[0].question)
        find(:xpath, '//*[@id="learn-operation"]/div[2]/div[4]').click
        visit current_path
        expect(page).to have_content(tangos[0].question)

        find(:id, "config-no-#{my_wn.id}").click
        find(:id, 'continue').click
        find(:xpath, "//*[contains(@class, 'close-btn')]").click
        find(:xpath, '//*[@id="learn-operation"]/div[2]/div[4]').click
        expect(page).to have_content(tangos[1].question)
        visit current_path
        expect(page).to have_content(tangos[1].question)
      end

      example '単語表示の並びが設定によって反映されていること' do
        find(:id, "config-no-#{my_wn.id}").click
        find(:id, 'sort').find("option[value='desc']").select_option
        find(:xpath, "//*[contains(@class, 'close-btn')]").click
        expect(page).to have_content(tangos[-1].question)
      end

      example '文字サイズの設定が反映されること' do
        find(:id, "config-no-#{my_wn.id}").click
        find(:id, 'font_size').find("option[value='40']").select_option
        find(:xpath, "//*[contains(@class, 'close-btn')]").click
        expect(find(:id, 'question-text').native.css_value('font-size')).to eq('40px')
      end

      example '正解ボタンと間違いボタンをクリックして、正解率の表示に反映されること' do
        find('#learn-wrapper').click
        find(:id, "correct-btn").click
        find(:xpath, '//*[@id="learn-operation"]/div[2]/div[2]').click
        expect(find(:id,'trial-count')).to have_content("1")
        expect(find(:id,'correct-ratio')).to have_content("100")
        find('#learn-wrapper').click
        find(:id, "wrong-btn").click
        find(:xpath, '//*[@id="learn-operation"]/div[2]/div[2]').click
        expect(find(:id,'trial-count')).to have_content("2")
        expect(find(:id,'correct-ratio')).to have_content("50")
      end
    end
  end
end

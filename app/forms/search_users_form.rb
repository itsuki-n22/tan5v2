class SearchUsersForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search_word, :string

  def search
    scope = User.distinct
    scope = splited_search_words.map { |splited_word| scope.search_word_contain(splited_word) }.inject { |result, scp| result.or(scp) } if splited_search_words.present?
    scope
  end

  private

  def splited_search_words
    search_word.strip.split(/[[:blank:]]+/)
  end
end

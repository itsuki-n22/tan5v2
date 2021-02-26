class FavoritesController < Base
  before_action :require_login, only: %i[create destroy]

  def create
    @favorite = current_user.favorites.build(wordnote_id: params[:wordnote_id])
    @favorite.save
  end

  def destroy
    @favorite = current_user.favorites.find(params[:id])
    @favorite.destroy
  end

end

class FavoritesController < Base

  def change
    @favorite = @current_user.favorites.find_by(wordnote_id: favorite_params[:wordnote_id])
    @wordnote_id = favorite_params[:wordnote_id]
    if @favorite
      @favorite.destroy
      if @current_user.id.to_s == favorite_params[:user_id] || @current_user.id == @favorite.user_id
        render action: 'destroy'
      end
    else
      @current_user.favorites.build(wordnote_id: favorite_params[:wordnote_id]).save
    end
  end

  private

  def favorite_params
    params.require(:favorite).permit(:user_id, :wordnote_id)
  end
end

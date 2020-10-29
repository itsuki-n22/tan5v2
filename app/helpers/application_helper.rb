module ApplicationHelper
  def view_title
    if @title
      @title + ' | tan5'
    else
      'tan5'
    end
  end
end

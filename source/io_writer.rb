module IOWriter extend self
  FG_RED_SQ = "\e[31m"
  FG_GREEN_SQ = "\e[32m"
  FG_WHITE_SQ = "\e[37m"
  END_SQ = "\e[0m"

  def write(message, style = nil)
    color_sq = get_color_sq(style)
    print "#{color_sq}#{message}#{END_SQ}"
  end

  private

  def get_color_sq(style)
    if style == :alert
      FG_RED_SQ
    elsif style == :success
      FG_GREEN_SQ
    else
      FG_WHITE_SQ
    end
  end
end


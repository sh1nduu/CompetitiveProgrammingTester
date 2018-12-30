module IOWriter extend self
  FG_RED_SQ = "\e[31m"
  FG_GREEN_SQ = "\e[32m"
  FG_WHITE_SQ = "\e[37m"
  END_SQ = "\e[0m"
  INDENT = "  "

  def write(message, style=nil, nest=0)
    color_sq = get_color_sq(style)
    output_message = "#{INDENT*nest}#{color_sq}#{message}#{END_SQ}"
    print output_message
  end
  alias w write

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


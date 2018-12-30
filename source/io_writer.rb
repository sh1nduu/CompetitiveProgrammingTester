module IOWriter
  module_function

  FG_RED_SQ = "\e[31m".freeze
  FG_GREEN_SQ = "\e[32m".freeze
  FG_WHITE_SQ = "\e[37m".freeze
  END_SQ = "\e[0m".freeze
  INDENT = '  '.freeze

  def write(message, style = nil, nest = 0)
    color_sq = get_color_sq(style)
    output_message = "#{INDENT * nest}#{color_sq}#{message}#{END_SQ}"
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

class TestCase
  attr_reader :id, :input, :expect, :output, :precision
  def initialize(id, data, lang, precision)
    @id = id
    @input = data['input']
    @expect = data['expect']
    @language = lang
    @precision = precision
  end

  def execute
    require 'open3'
    @output, = Open3.capture3(@language.execute, stdin_data: @input)
    @result = if @precision.nil?
                @output == @expect
              else
                result_with_precision
              end
  end

  def success?
    @result
  end

  def failure?
    !success?
  end

  private

  def result_with_precision
    precision = @precision.to_i
    raise 'specify valid precision. use -p' if precision.zero?

    @expect.split("\n").zip(@output.split("\n")).detect do |e, o|
      equal_with_precision(e, o, precision)
    end.nil?
  end

  def equal_with_precision(lhs, rhs, precision)
    require 'bigdecimal'
    require 'bigdecimal/util'
    lhs = lhs.to_d.truncate(precision + 1)
    rhs = rhs.to_d.truncate(precision + 1)
    (lhs - rhs).abs > 0.1**precision
  end
end

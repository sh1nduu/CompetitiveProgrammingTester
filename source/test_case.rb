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
    thread = Thread.new do
      @output, = Open3.capture3(@language.execute, stdin_data: @input)
    end
    thread.join(2)
    @output ||= 'Time Limit Exceeded'
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
    @expect.split("\n").zip(@output.split("\n")).detect do |expect, output|
      out_of_tolerance?(expect, output)
    end.nil?
  end

  def out_of_tolerance?(lhs, rhs)
    require 'bigdecimal'
    require 'bigdecimal/util'
    lhs = lhs.to_d.truncate(@precision + 1)
    rhs = rhs.to_d.truncate(@precision + 1)
    (lhs - rhs).abs > 0.1**@precision
  end
end

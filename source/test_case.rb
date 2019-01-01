class TestCase
  attr_reader :id, :input, :expect, :output
  def initialize(id, data, lang)
    @id = id
    @input = data['input']
    @expect = data['expect']
    @language = lang
  end

  def execute
    require 'open3'
    @output, = Open3.capture3(@language.execute, stdin_data: @input)
    @result = @output == @expect
  end

  def success?
    @result
  end

  def failure?
    !success?
  end
end

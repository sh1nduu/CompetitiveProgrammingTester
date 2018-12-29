class TestCase
  attr_reader :id, :input, :expect, :output
  def initialize(id, data, lang)
    @id = id
    @input = data["input"]
    @expect = data["expect"]
    @language = lang
  end

  def execute
    IO.popen(@language.execute, "r+") do |io|
      io.puts @input
      io.close_write
      @output = io.readlines.join()
      @result = @output == @expect
    end
  end

  def success?
    @result
  end

  def failure?
    !success?
  end
end


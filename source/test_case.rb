class TestCase
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

  def draw_result
    IOWriter.write("CASE #{@id}: ")
    if @result
      IOWriter.write("SUCCESS\n", :success)
    else
      IOWriter.write("FAILED\n", :alert)
      IOWriter.write("\tExpected: #{@expect}\n", :alert)
      IOWriter.write("\tBut got: #{@output}\n", :alert)
    end
  end
end


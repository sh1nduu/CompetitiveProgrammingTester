require 'yaml'

TESTCASE_FILE = "testcase.yml"
EXECUTE_COMMAND = "./main"
COMPILE_COMMAND = "g++ main.cpp -o main -std=c++14"

class TestCase
  def initialize(id, data)
    @id = id
    @input = data["input"]
    @expect = data["expect"]
  end

  def execute
    IO.popen(EXECUTE_COMMAND, "r+") do |io|
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

module Main extend self
  def run
    yaml = load_yaml

    return unless system(COMPILE_COMMAND)

    yaml["testcase"].each.with_index(1) do |testcase, i|
      tc = TestCase.new(i, testcase)
      tc.execute
      tc.draw_result
    end
  end

  private

  def load_yaml
    yaml = nil
    File.open(TESTCASE_FILE) do |f|
      yaml = f.read
    end

    YAML.load(yaml)
  end
end

Main.run

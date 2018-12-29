require 'yaml'
require 'optparse'
require './source/io_writer'
require './source/language_map'
require './source/test_case'

module Main extend self
  def run
    params = ARGV.getopts('l:s:t:')

    raise "testcase file is unspecified. use -t" unless params["t"]
    yaml = load_yaml(params["t"])

    language = LanguageMap::get(params["l"], params["s"])

    raise "language is unsupported. verify -l" unless language
    return unless system(language.compile)

    yaml["testcase"].each.with_index(1) do |testcase, i|
      tc = TestCase.new(i, testcase, language)
      tc.execute
      tc.draw_result
    end
  end

  private

  def load_yaml(testcase_file)
    yaml = nil
    File.open(testcase_file) do |f|
      yaml = f.read
    end

    YAML.load(yaml)
  end
end

Main.run

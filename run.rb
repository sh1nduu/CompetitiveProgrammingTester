#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require_relative './source/io_writer'
require_relative './source/language_map'
require_relative './source/result_view'
require_relative './source/test_case'
require_relative './source/test_case_view'

module Main
  module_function

  def run
    params = ARGV.getopts('l:s:t:n:')
    raise 'testcase file is unspecified. use -t' unless params['t']

    language = LanguageMap.get(params['l'], params['s'])
    raise 'language is unsupported. verify -l' unless language
    return unless system(language.compile)

    yaml = load_yaml(params['t'])
    testcase = yaml['testcase']
    n = params['n'].to_i
    testcases = execute_testcases(testcase, language, n)

    ResultView.new(testcases).draw
  end

  def execute_testcases(testcases, language, number)
    if !number.zero? && testcases.size < number
      raise 'specified test case does not exist. verify -n'
    end

    testcases.map.with_index(1) do |testcase, i|
      next unless number.zero? || i == number

      tc = TestCase.new(i, testcase, language)
      tc.execute
      TestCaseView.new(tc).draw
      tc
    end.compact
  end

  def load_yaml(testcase_file)
    yaml = nil
    File.open(testcase_file) do |f|
      yaml = f.read
    end

    YAML.safe_load(yaml)
  end
end

Main.run

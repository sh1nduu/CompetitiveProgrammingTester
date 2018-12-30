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
    params = ARGV.getopts('l:s:t:')
    raise 'testcase file is unspecified. use -t' unless params['t']

    language = LanguageMap.get(params['l'], params['s'])
    raise 'language is unsupported. verify -l' unless language
    return unless system(language.compile)

    yaml = load_yaml(params['t'])
    testcases = execute_testcases(yaml['testcase'], language)
    ResultView.new(testcases).draw
  end

  def execute_testcases(testcases, language)
    testcases.map.with_index(1) do |testcase, i|
      tc = TestCase.new(i, testcase, language)
      tc.execute
      TestCaseView.new(tc).draw
      tc
    end
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

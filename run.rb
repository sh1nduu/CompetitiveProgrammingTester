#!/usr/bin/env ruby

require_relative './source/io_writer'
require_relative './source/language_map'
require_relative './source/result_view'
require_relative './source/test_case'
require_relative './source/test_case_view'

module Main
  module_function

  def run
    require 'optparse'
    params = ARGV.getopts('l:s:t:n:p:')
    raise 'testcase file is unspecified. use -t' unless params['t']

    language = get_language(params['l'], params['s'])
    return unless system(language.compile)

    yaml = load_yaml(params['t'])
    testcases = execute_testcases(yaml['testcase'],
                                  language,
                                  params)

    ResultView.new(testcases).draw
  end

  def get_language(identifier, source)
    language = LanguageMap.get(identifier, source)
    raise 'language is unsupported. verify -l' unless language

    language
  end

  def execute_testcases(testcases, language, params)
    number, precision = validate_params(params, testcases)
    testcases.map.with_index(1) do |testcase, i|
      next unless number.zero? || i == number

      tc = TestCase.new(i, testcase, language, precision)
      tc.execute
      TestCaseView.new(tc).draw
      tc
    end.compact
  end

  def validate_params(params, testcases)
    number = validate_number(params['n'], testcases)
    precision = validate_precision(params['p'])
    [number, precision]
  end

  def validate_number(number, testcases)
    number = number.to_i
    if !number.zero? && testcases.size < number
      raise 'specified test case does not exist. verify -n'
    end

    number
  end

  def validate_precision(precision)
    if precision
      precision = precision.to_i
      raise 'specify valid precision. use -p' if precision.zero?
    end

    precision
  end

  def load_yaml(testcase_file)
    yaml = nil
    File.open(testcase_file) do |f|
      yaml = f.read
    end

    require 'yaml'
    YAML.safe_load(yaml)
  end
end

Main.run

#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require 'fileutils'
require 'net/http'
require 'uri'

INTERVAL = 2 # crawling interval seconds

CPP_DEFAULT = <<-CODE.freeze
#include <iostream>

int main() {
  // Write your code here.
  return 0;
}
CODE

class TestCase
  attr_reader :data

  def initialize(problem_id, index)
    @problem_id = problem_id
    @index = index
    @type = 'in'
    @data = {}
  end

  def switch
    @type = @type == 'in' ? 'out' : 'in'
  end

  def increment
    @index += 1
  end

  def description
    "#{@problem_id}/#{@index}/#{@type} URL: #{url_string}"
  end

  def fetch
    response = Net::HTTP.get_response(uri)
    sleep(INTERVAL)

    raise "HTTP Error #{response.code}" if response.code != '200'
    raise 'Not available' if unavailable?(@index, @problem_id, response.body)

    @body = response.body
    store_body
  end

  private

  def uri
    URI.parse(url_string)
  end

  def url_string
    testcase_url = 'https://judgedat.u-aizu.ac.jp/testcases/'
    "#{testcase_url}#{@problem_id}/#{@index}/#{@type}"
  end

  def store_body
    key = @type == 'in' ? 'input' : 'expect'
    @data[key] = @body
  end

  def unavailable?(index, problem_id, text)
    text == unavailable_text(index, problem_id)
  end

  def unavailable_text(index, problem_id)
    "/* Test case ##{index} for problem #{problem_id} is not available. */"
  end
end

class Problem
  attr_reader :id
  def initialize(id)
    @id = id
  end

  def write_code
    file_path = "#{save_path}main.cpp"
    return false if File.exist?(file_path)

    File.open(file_path, 'w+') do |f|
      f.write(CPP_DEFAULT)
    end
    true
  end

  def write_yaml(data)
    File.open("#{save_path}testcase.yml", 'w+') do |f|
      f.write(data)
    end
  end

  def create_dir
    FileUtils.mkdir_p(save_path) unless FileTest.exist?(save_path)
  end

  def save_path
    "./#{@id}/"
  end
end

module Main
  module_function

  def run
    params = ARGV.getopts('i:')

    problem_id = params['i']
    raise 'specify problem_id. use -i' unless problem_id

    problem = Problem.new(problem_id)
    problem.create_dir
    puts 'Created a bootstrap code.' if problem.write_code

    testcase = TestCase.new(problem.id, 1)
    yaml = { 'testcase' => [] }

    puts 'Started fetching test cases.'
    begin
      loop do
        testdata = fetch_test_inout(testcase)
        yaml['testcase'] << testdata
      end
    rescue RuntimeError
      puts 'Available testcases are loaded.'
    ensure
      problem.write_yaml(yaml.to_yaml)
      puts 'Finished writing a file.'
    end
  end

  def fetch_test_inout(testcase)
    testcase.fetch
    puts "Loaded: #{testcase.description}"
    testcase.switch

    testcase.fetch
    puts "Loaded: #{testcase.description}"
    testcase.increment
    testcase.switch

    testcase.data.dup
  end
end

Main.run

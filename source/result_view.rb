class ResultView
  include IOWriter

  def initialize(testcases)
    @testcases = testcases
    @failure_cases = @testcases.select(&:failure?)
    @success_count = @testcases.size - @failure_cases.size
    @succeeded_all = @failure_cases.size.zero?
  end

  def draw
    w("Result:\n")
    w("Passed: #{@success_count}/#{@testcases.size}\n", :success, 1)
    if @succeeded_all
      w("Congratulation! All cases succeeded! 🎉\n", :success, 1)
    else
      w("Failed: #{failure_numbers.join(", ")}\n", :alert, 1)
    end
  end

  private
  def failure_numbers
    @failure_cases.map(&:id)
  end
end

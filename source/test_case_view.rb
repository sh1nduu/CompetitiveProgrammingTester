class TestCaseView
  include IOWriter

  def initialize(testcase)
    @tc = testcase
  end

  def draw
    w("CASE #{@tc.id}: ")
    if @tc.success?
      w("SUCCESS\n", :success)
    else
      w("FAILED\n", :alert)
      draw_failure_detail
    end
  end

  private

  def draw_failure_detail
    w("Expected:\n", :alert, 1)
    draw_lines(@tc.expect)
    w("But got:\n", :alert, 1)
    draw_lines(@tc.output)
  end

  def draw_lines(text)
    text.split("\n").each do |line|
      w("#{line}\n", :alert, 2)
    end
  end
end

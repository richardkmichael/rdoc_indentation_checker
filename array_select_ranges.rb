class Array

  def select_ranges &block

    ranges = []

    self.each_with_index do |element, index|

      block_result = yield element

      if block_result && ! current_range.open?
        start_range_at(index)
      elsif ! block_result && current_range.open?
        end_range_at(index - 1)
      end

      ranges << current_range.build if current_range.complete?

    end

    # If all elements satisfied the criteria, we finished without closing ; close now.
    if current_range.open?
      end_range_at(self.length - 1)
      ranges << current_range.build
    end

    ranges
  end

  private

  def start_range_at integer
    current_range.open_at = integer
  end

  def end_range_at integer
    current_range.close_at = integer
  end

  def current_range
    @current_range ||= ArrayRange.new
  end

  class ArrayRange
  # class CurrentRange # --> Better as a singleton class?  There only ever one range.

    def initialize
      @start = @end = nil
    end

    def open_at= integer
      @start = integer
    end

    def close_at= integer
      @end = integer
    end

    def build
      if @start && @end
        range = Range.new(@start, @end)
      elsif @start && ! @end
        range = Range.new(@start, self.length)
      elsif ! @start && @end
        # We should never get here!
      end

      # Reset endpoints.  Makes the case for a singleton class?
      @start = @end = nil

      range
    end

    def open?
      @start != nil
    end

    def closed?
      @end != nil
    end

    def complete?
      @start && @end
    end
  end

end

require_relative 'rdoc_indentation_checker'
require 'minitest/autorun'

require 'pry'

class RDocIndentationTest < MiniTest::Unit::TestCase

  def setup
    @file_with_two_comments = StringIO.new <<-COMMENT_FILE
/*
 *  call-seq:
 *    enum.slice_before(pattern)                             -> an_enumerator
 *
 *  Some text.
 *
 */
static VALUE enum_slice_before(int argc, VALUE *argv, VALUE enumerable)
{

}

/*
 *  call-seq:
 *    enum.chunk(pattern)                             -> an_enumerator
 *
 *  Some text.
 *
 */
static VALUE enum_chunk(int argc, VALUE *argv, VALUE enumerable)
{

}
COMMENT_FILE

    @file_with_no_comments = StringIO.new <<-COMMENT_FILE
/*
 *  Some text, this is not a call-seq: comment.
 *
 */
static VALUE enum_slice_before(int argc, VALUE *argv, VALUE enumerable)
{

}
COMMENT_FILE

  end

  def test_call_sequence_line_indentation

   comment_indented_with_two_spaces = <<-COMMENT
/*
 *  call-seq:
 *    enum.slice_before(pattern)                             -> an_enumerator
 *    enum.slice_before { |elt| bool }                       -> an_enumerator
 *    enum.slice_before(initial_state) { |elt, state| bool } -> an_enumerator
 *
 *  So "each" method can be called as follows.
 *
 */
COMMENT

    assert_equal 2, call_sequence_line_indentation(comment.split("\n"))
  end

  def test_find_call_sequence_comments_finds_two_comments
    call_sequence_comments = find_call_sequence_comments(@file_with_two_comments)
    assert_equal 2, call_sequence_comments.length
  end

  def test_find_c_comments_finds_two_comments
    c_comments = find_c_comments(@file_with_two_comments)
    assert_equal 2, c_comments.length
  end

  def test_is_call_sequence_comment_detects_correctly
    comment = @file_with_no_comments.readlines
    refute is_call_sequence_comment?(comment)

    comment = @file_with_two_comments.readlines
    assert is_call_sequence_comment?(comment)
  end

  def test_comment_lines_indentations
    comment = <<-COMMENT
/*
 *  call-seq:
 *    enum.slice_before(pattern)                             -> an_enumerator
 *    enum.slice_before { |elt| bool }                       -> an_enumerator
 *    enum.slice_before(initial_state) { |elt, state| bool } -> an_enumerator
 *
 *  So "each" method can be called as follows.
 *
 */
COMMENT

    indentations = { 0 => 0,
                     1 => 2,
                     2 => 4,
                     3 => 4,
                     4 => 4,
                     5 => 0,
                     6 => 2,
                     7 => 0,
                     8 => 0 }

    assert_equal indentations, comment_line_indentations(comment.split("\n"))
  end

  def test_comment_has_consistent_indentation_correctly_detects_consistency
    consistently_indented_comment = <<-CONSISTENT_COMMENT
/*
 *  call-seq:
 *    enum.slice_before(pattern)                             -> an_enumerator
 *    enum.slice_before { |elt| bool }                       -> an_enumerator
 *    enum.slice_before(initial_state) { |elt, state| bool } -> an_enumerator
 *
 *  So "each" method can be called as follows.
 *
 */
CONSISTENT_COMMENT

    inconsistently_indented_comment = <<-INCONSISTENT_COMMENT
/*
 * call-seq:
 *    enum.slice_before(pattern)                             -> an_enumerator
 *    enum.slice_before { |elt| bool }                       -> an_enumerator
 *    enum.slice_before(initial_state) { |elt, state| bool } -> an_enumerator
 *
 *  So "each" method can be called as follows.
 *
 */
INCONSISTENT_COMMENT

    # assert comment_has_consistent_indentation?(consistently_indented_comment.split("\n"))
    refute comment_has_consistent_indentation?(inconsistently_indented_comment.split("\n"))

  end

end

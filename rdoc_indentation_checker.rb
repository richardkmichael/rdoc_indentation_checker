# FIXME:
#   class Comment ; end
#   function names should be verbs: "calculate_comment_line_indentations", etc.
#   consistency indentation is tricky -- what are rdoc's rules?

# FIXME: Re-implement with Enumerable#chunk.
require_relative 'array_select_ranges'

CALL_SEQ_REGEX = /\A +\*( +)call-seq:/
C_COMMENT_LINE_REGEX = /\A ?(\/)?\* ?(.*)/

# files.each do |file|
#   call_sequence_comments(file).each do |comment|
#     puts "Indentation warning: #{file}" unless comment_has_consistent_indentation? comment
#   end
# end

def call_sequence_comments file
  File.open filename do |file|
   find_call_sequence_comments file
  end
end

def find_call_sequence_comments file
  # Could be done in one multiline regex.  Fail.
  c_comments = find_c_comments file
  c_comments.select { |comment| is_call_sequence_comment? comment }
end

def find_c_comments file
  data = file.readlines # Keep an array; otherwise, we must rewind after each access.
  c_comment_ranges = data.select_ranges { |line| line =~ C_COMMENT_LINE_REGEX }
  c_comment_ranges.map { |comment_range| data[comment_range] }
end

def is_call_sequence_comment? comment
  comment.any? { |line| line =~ CALL_SEQ_REGEX }
end

def comment_has_consistent_indentation? comment

  indentation_unit = call_sequence_line_indentation comment
  indentations = comment_line_indentations comment

  has_consistent_indentation = true

  # To add line numbers: "indentations.each_with_index.map { |line_num, ind| ... }"
  indentations.map do |line_number, indentation|
    previous_indentation = indentations.fetch(line_number - 1, 0)

    has_consistent_indentation = false unless
      (indentation - previous_indentation).abs % indentation_unit

      # FIXME: Check how rdoc handles " * call-seq: " single space, then double space on
      # following lines.

  end

  has_consistent_indentation
end

def call_sequence_line_indentation comment
  call_sequence_line_index = comment.find_index { |line| line =~ /\A +\* +call-seq:/ }
  indentations = comment_line_indentations comment
  indentations[call_sequence_line_index]
end

def comment_line_indentations comment
  comment.each_with_index.inject({}) do |indentations, (line_data, line_number)|
    indentations.merge({ line_number => line_indentation(line_data) })
  end
end

def line_indentation line
  line[/\A *\/?\*( *).*\z/, 1].length
end

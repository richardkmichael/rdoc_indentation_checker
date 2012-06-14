/*
 *  call-seq:
 *    enum.slice_before(pattern)                             -> an_enumerator
 *
 *      # iterate over ChangeLog entries.
 *      open("ChangeLog") { |f|
 *        f.slice_before(/\A\S/).each { |e| pp e }
 *      }
 *
 *  So "each" method can be called as follows.
 *
 * So each mail can be extracted by slice before Unix From line.
 *
 */

static VALUE enum_slice_before(int argc, VALUE *argv, VALUE enumerable)
{

}

void Init_Enumerable(void)
{
  rb_mEnumerable = rb_define_module("Enumerable");
  rb_define_method(rb_mEnumerable, "slice_before", enum_slice_before, -1);
}

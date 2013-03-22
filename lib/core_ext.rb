class Hash
	# File activesupport/lib/active_support/core_ext/hash/diff.rb, line 10
  def diff(other)
	  dup.delete_if { |key, value| other[key] == value }
    .merge!(other.dup.delete_if { |key, value| has_key?(key) })
	end
end
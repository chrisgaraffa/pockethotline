class Callcategory < ActiveRecord::Base
	# Relationships
	has_many :calls

	# Callbacks
	before_create :set_sort_order
	after_destroy :reorder_categories

	# Validation
	validates :name, presence: true, uniqueness: { case_sensitive: false }

	private
		def set_sort_order
			self.sort_order = Callcategory.maximum(:sort_order).to_i + 1 # .to_i because the .maximum returns nil instead of 0 for no records
		end

		def reorder_categories
			categories = Callcategory.order(:sort_order)
			categories.each_with_index do |cat, idx|
				cat.sort_order = idx + 1
				cat.save
			end
		end
end

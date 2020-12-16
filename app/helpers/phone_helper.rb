module PhoneHelper
	# TODO: Eventually should handle non-US number formats.
	# num: Number or String representing a phone number
	# returns: String prepresenting the phone number in E.164 format
	def convert_to_e164(num)
		# Remove non-numeric characters
		transformedNumber = num.to_s.gsub(/\D/, '')

		# Drop leading 1 as international dialer
		transformedNumber = transformedNumber[1..-1] if transformedNumber[0] == '1'

		if transformedNumber.length != 10
			raise "#{num} is not 10 characters can't be converted to E.164 format"
		end
		
		"+1#{transformedNumber}"
	end
end

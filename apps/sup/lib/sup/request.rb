require "uri"
require "net/http"

class Request

	attr_accessor :username, :machine, :email, :urgent, :subject, :description
		
	def initialize
		@username = ENV['LOGNAME'] || ENV['USERNAME'] || ENV['USER']
		@machine = ENV['SHORT_HOSTNAME']
		@email = nil
		@urgent = 0
	end

	def submit(url = "http://www.tardis.ed.ac.uk/~ediblespread/rubytest/test.php")

		# Fire off the request. Currently uses a test php file located on my
		# (Stephen McGruer) website which merely echos the POST values.
		#
		# We need to find out how to test that we're addressing the "urgent"
		# keyword properly without spamming CS. Maybe ask them what they try and
		# match?
		#
		# Will also need to guard against 404, 403, no connection, etc.
		params = {
		  :username => self.username,
		  :machine_name => self.machine,
		  :email => self.email,
		  :short_message => self.subject,
		  :urgent => self.urgent,
		  :long_message => self.description
		}
		
		response = Net::HTTP.post_form(URI.parse(url), params)

	end

end
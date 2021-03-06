class Report

	attr_accessor :report_result_hash
	require 'error'

	def initialize(year, grade, state, test_type, local)
		@year = year
		@grade_id = Grade.grade_id_by_description(grade)
		@state_id = State.state_id_by_description(state)
		@test_type = test_type
		@local = local
	end

	def request_report
		ideb = request_ideb
		rates = request_rate

		@report_result_hash = {:ideb => ideb,
		 :rates => rates,
		 :year => @year,
		 :grade => @grade_id}
	end

	private
	def request_ideb
		begin
			raise Error::NoDataToSelectedYear if @year.to_i > Ideb.maximum(:year)
			raise Error::NoDataForSelectedGrade if @year.to_i%2 == 0 && @grade_id == 9
			@ideb = Ideb.new(@year,@grade_id,@state_id)
			@ideb.request_ideb_report
		rescue
			ideb = {:status => "unavailable"}
		end
	end

	def request_rate
		begin
			raise Error::NoDataToSelectedYear unless Rate.exists?(:year => @year, :state_id => @state_id, :local => @local, :test_type => @test_type,
			 :grade_id => @grade_id)
			@rates = Rate.new(@year,@grade_id,@state_id,@test_type,@local)
			@rates.request_rate_report
		rescue
			rates = {:status => "unavailable"}
		end
	end

end

class Rate < ActiveRecord::Base
	include ReportHelper
	attr_accessor :rate_hash, :evasion_average, :performance_average, :distortion_average

	def initialize(year, id_grade, id_state)
		@year = year
		@id_grade = id_grade
		@id_state = id_state
		@final_year = Rate.final_year_avaiable( year, id_grade, id_state )
		
	end

	def self.final_year_avaiable( year, id_grade, id_state )

		final_year = ""
		#to use in the loop below , increments in one each loop
		id_grade_local = id_grade

		#will pick the last year avaiable and add 1
		local_final_year = Rate.all.pluck(:year).max.to_i + 1

		#loop to test if the line in the table with the params year and id_grade are empty
		(year.to_i..local_final_year).each do |year_test|

			table_line = Rate.where(:year => year_test,:id_grade => id_grade_local , :id_state => id_state)

			id_grade_local = id_grade_local.to_i + 1 #increments each loop
			
			#if table_line is empty, means that we have a final year to use
			if table_line.empty?

				final_year = (year_test - 1).to_s
				break
			end
		end

		return final_year

	end

	def request_rate_report
		@rate_request_result = Array.new
		@evasion_result = Array.new
		@performance_result = Array.new
		@distortion_result = Array.new
		#auxiliar variable to receive the given id_grade and make casts to the value.
		local_id_grade = @id_grade

		(@year..@final_year).each do |year|
			current_rate = request_rate(year,@id_state,local_id_grade)
			#increments the id_grade through years.
			local_id_grade = (local_id_grade.to_i + 1).to_s 
			@evasion_result.push(current_rate.evasion)
			@performance_result.push(current_rate.performance)
			@distortion_result.push(current_rate.distortion)

			@rate_request_result.push(current_rate)
		end
		request_analise_data
		generate_hash_result
	end


	def generate_hash_result
		@rate_hash = {:evasion => @evasion_result,
		 	:performance => @performance_result,
		 	:distortion => @distortion_result,
			:evasion_average => @evasion_average,
			:performance_average => @performance_average,
		  	:distortion_average => @distortion_average,
		  	:evasion_standard_deviation => @standard_deviation_evasion,
		  	:performance_standard_deviation => @standard_deviation_performance,
		  	:distortion_standard_deviation => @standard_deviation_distortion,
			:evasion_variance => @variance_evasion,
		  	:performance_variance => @variance_performance,
		  	:distortion_variance => @variance_distortion}
	end

	def request_analise_data
		request_average_to_evasion
		request_average_to_performance
		request_average_to_distortion
		request_standard_deviation_evasion
		request_standard_deviation_performance
		request_standard_deviation_distortion
		request_variance_evasion
		request_variance_performance
		request_variance_distortion
	end

	def request_average_to_evasion
		@evasion_average = ReportHelper.compute_average_for(@evasion_result)
	end
	private :request_average_to_evasion

	def request_average_to_performance
		@performance_average = ReportHelper.compute_average_for(@performance_result)
	end
	private :request_average_to_performance

	def request_average_to_distortion
		@distortion_average = ReportHelper.compute_average_for(@distortion_result)
	end
	private :request_average_to_distortion

	def request_standard_deviation_evasion
		@standard_deviation_evasion = ReportHelper.compute_standard_deviation(@evasion_result)
	end
	private :request_standard_deviation_evasion

	def request_standard_deviation_performance
		@standard_deviation_performance = ReportHelper.compute_standard_deviation(@performance_result)
	end
	private :request_standard_deviation_performance

	def request_standard_deviation_distortion
		@standard_deviation_distortion = ReportHelper.compute_standard_deviation(@distortion_result)
	end
	private :request_standard_deviation_distortion

	def request_variance_evasion
		@variance_evasion = ReportHelper.compute_variance(@evasion_result)
	end
	private :request_variance_evasion

	def request_variance_performance
		@variance_performance = ReportHelper.compute_variance(@performance_result)
	end
	private :request_variance_performance

	def request_variance_distortion
		@variance_distortion = ReportHelper.compute_variance(@distortion_result)
	end
	private :request_variance_distortion


	def request_rate(year,id_state,id_grade)
		return Rate.where(:year => year, :id_state => id_state, :id_grade => id_grade).first
	end
	private :request_rate
end

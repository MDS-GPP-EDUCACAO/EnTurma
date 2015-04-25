class ReportController < ApplicationController

	def index
		
	end

	def request_report
		@report = Report.new(params[:year],params[:id_grade],params[:id_state],params[:final_year])

		report_result_hash = {:prova_brasil => @report.prova_brasil.prova_brasil_hash, :rates => @report.rates.rate_hash,
		 :year => @report.year}

		respond_to do |format|
			format.json { render json: report_result_hash}
		end
		puts report_result_hash
	end


end
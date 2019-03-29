class CalendarsController < ApplicationController
  def weekly_schedule
    render json: Section.all.order(:weekday)
  end
end

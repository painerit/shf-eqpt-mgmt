class ScanDueSchedulesJob < ApplicationJob
  queue_as :default

  def perform
    Notifications::ScanDueSchedules.new.call
  end
end
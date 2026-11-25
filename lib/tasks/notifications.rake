namespace :notifications do
  desc "Сканирует сроки поверки и создаёт уведомления"
  task scan: :environment do
    result = Notifications::ScanDueSchedules.new.call
    puts "Создано уведомлений: #{result.created}"
    puts "Пропущено дубликатов: #{result.skipped}"
  end
end
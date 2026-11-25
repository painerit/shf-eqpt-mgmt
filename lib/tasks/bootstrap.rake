namespace :app do
  desc "Создаёт справочники и администратора без демонстрационных данных"
  task bootstrap: :environment do
    roles = {
      "admin" => "Администратор",
      "metrologist" => "Метролог",
      "engineer" => "Инженер",
      "customer" => "Заказчик"
    }.map do |code, name|
      Role.find_or_create_by!(code: code) { |role| role.name = name }
    end.index_by(&:code)

    departments = {
      "MS" => "Метрологическая служба",
      "SVC" => "Отдел СВЧ-измерений",
      "DESIGN" => "Конструкторский отдел",
      "QA" => "Служба качества"
    }.map do |code, name|
      Department.find_or_create_by!(code: code) { |department| department.name = name }
    end.index_by(&:code)

    {
      "GENERATOR" => "Генератор СВЧ",
      "AMPLIFIER" => "Усилитель мощности СВЧ",
      "SPECTRUM" => "Анализатор спектра",
      "POWER_METER" => "Ваттметр проходящей мощности",
      "FREQ_COUNTER" => "Частотомер",
      "ATTENUATOR" => "Аттенюатор",
      "COUPLER" => "Направленный ответвитель",
      "CALIBRATOR" => "Калибратор"
    }.each do |code, name|
      EquipmentType.find_or_create_by!(code: code) { |type| type.name = name }
    end

    [
      ["Keysight Technologies", "США", "https://www.keysight.com"],
      ["Rohde & Schwarz", "Германия", "https://www.rohde-schwarz.com"],
      ["Anritsu", "Япония", "https://www.anritsu.com"],
      ["Tektronix", "США", "https://www.tek.com"],
      ["НПФ «Микран»", "Россия", "https://micran.ru"],
      ["АО «НПП «Исток»", "Россия", "https://istokmw.ru"]
    ].each do |name, country, website|
      Manufacturer.find_or_create_by!(name: name) do |manufacturer|
        manufacturer.country = country
        manufacturer.website = website
      end
    end

    [
      ["ГОСТ 8.569-2000", "Государственная поверочная схема для средств измерений мощности электромагнитных колебаний", "gost"],
      ["ГОСТ Р 8.596-2002", "Метрологическое обеспечение измерительных систем", "gost"],
      ["МИ 2630-2000", "Методика поверки ваттметров проходящей мощности", "method"],
      ["МИ 1947-88", "Методика поверки генераторов СВЧ", "method"],
      ["ГОСТ 8.414-2002", "Государственная поверочная схема для средств измерений частоты", "gost"],
      ["МП 1234-2024", "Методика поверки анализаторов спектра", "method"]
    ].each do |doc_number, title, doc_type|
      NormativeDocument.find_or_create_by!(doc_number: doc_number) do |document|
        document.title = title
        document.doc_type = doc_type
      end
    end

    email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
    admin = User.find_or_initialize_by(email: email)

    if admin.new_record?
      password = ENV["ADMIN_PASSWORD"]
      raise "Задайте ADMIN_PASSWORD для создания администратора" if password.blank?

      admin.full_name = ENV.fetch("ADMIN_NAME", "Администратор Системы")
      admin.role = roles.fetch("admin")
      admin.department = departments.fetch("MS")
      admin.password = password
      admin.password_confirmation = password
      admin.active = true
    end

    admin.save!
    puts "Bootstrap завершён. Администратор: #{admin.email}"
  end
end
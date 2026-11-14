# Демонстрационные данные для локального запуска.
# Скрипт идемпотентен: повторный `bin/rails db:seed` не создаёт дубликаты.

puts "Seeding roles..."
roles = {
  "admin" => ["Администратор", "Полный доступ к системе и управлению пользователями"],
  "metrologist" => ["Метролог", "Ведение реестра, графиков поверок и нормативных документов"],
  "engineer" => ["Инженер", "Выполнение поверок и внесение результатов измерений"],
  "customer" => ["Заказчик", "Просмотр состояния закреплённого оборудования"]
}.to_h do |code, (name, description)|
  role = Role.find_or_create_by!(code: code) do |record|
    record.name = name
    record.description = description
  end
  [code, role]
end

puts "Seeding departments..."
departments = {
  "MS" => ["Метрологическая служба", "Организация и контроль поверок"],
  "SVC" => ["Отдел СВЧ-измерений", "Разработка и эксплуатация СВЧ-оборудования"],
  "DESIGN" => ["Конструкторский отдел", "Проектирование СВЧ-устройств"],
  "QA" => ["Служба качества", "Контроль качества и метрологический надзор"]
}.to_h do |code, (name, description)|
  department = Department.find_or_create_by!(code: code) do |record|
    record.name = name
    record.description = description
  end
  [code, department]
end

puts "Seeding users..."
def seed_user(email:, full_name:, role:, department:)
  User.find_or_create_by!(email: email) do |user|
    user.full_name = full_name
    user.role = role
    user.department = department
    user.password = "password123"
    user.password_confirmation = "password123"
    user.active = true
  end
end

admin = seed_user(
  email: "admin@example.com",
  full_name: "Администратор Системы",
  role: roles.fetch("admin"),
  department: departments.fetch("MS")
)
metrologist = seed_user(
  email: "metrologist@example.com",
  full_name: "Иванова Мария Сергеевна",
  role: roles.fetch("metrologist"),
  department: departments.fetch("MS")
)
engineer = seed_user(
  email: "engineer@example.com",
  full_name: "Петров Алексей Викторович",
  role: roles.fetch("engineer"),
  department: departments.fetch("SVC")
)
customer = seed_user(
  email: "customer@example.com",
  full_name: "Сидоров Дмитрий Олегович",
  role: roles.fetch("customer"),
  department: departments.fetch("QA")
)

puts "Seeding equipment types..."
equipment_types = {
  "GENERATOR" => ["Генератор СВЧ", "Источники СВЧ-сигнала"],
  "AMPLIFIER" => ["Усилитель мощности СВЧ", "Усилители проходящей мощности"],
  "SPECTRUM" => ["Анализатор спектра", "Анализаторы спектра и сигналов"],
  "POWER_METER" => ["Ваттметр проходящей мощности", "Измерение мощности СВЧ"],
  "FREQ_COUNTER" => ["Частотомер", "Измерение частоты и интервалов"],
  "ATTENUATOR" => ["Аттенюатор", "Ослабление сигнала"],
  "COUPLER" => ["Направленный ответвитель", "Ответвление мощности"],
  "CALIBRATOR" => ["Калибратор", "Эталонные источники сигналов"]
}.to_h do |code, (name, description)|
  type = EquipmentType.find_or_create_by!(code: code) do |record|
    record.name = name
    record.description = description
  end
  [code, type]
end

puts "Seeding manufacturers..."
manufacturers = [
  ["Keysight Technologies", "США", "https://www.keysight.com"],
  ["Rohde & Schwarz", "Германия", "https://www.rohde-schwarz.com"],
  ["Anritsu", "Япония", "https://www.anritsu.com"],
  ["Tektronix", "США", "https://www.tek.com"],
  ["НПФ «Микран»", "Россия", "https://micran.ru"],
  ["АО «НПП «Исток»", "Россия", "https://istokmw.ru"]
].map do |name, country, website|
  Manufacturer.find_or_create_by!(name: name) do |manufacturer|
    manufacturer.country = country
    manufacturer.website = website
  end
end

puts "Seeding normative documents..."
normative_documents = [
  ["ГОСТ 8.569-2000", "Государственная поверочная схема для средств измерений мощности электромагнитных колебаний", "gost", Date.new(2000, 1, 1), nil],
  ["ГОСТ Р 8.596-2002", "Метрологическое обеспечение измерительных систем", "gost", Date.new(2002, 1, 1), nil],
  ["МИ 2630-2000", "Методика поверки ваттметров проходящей мощности", "method", Date.new(2000, 1, 1), nil],
  ["МИ 1947-88", "Методика поверки генераторов СВЧ", "method", Date.new(1988, 1, 1), Date.new(2027, 1, 1)],
  ["ГОСТ 8.414-2002", "Государственная поверочная схема для средств измерений частоты", "gost", Date.new(2002, 1, 1), nil],
  ["МП 1234-2024", "Методика поверки анализаторов спектра", "method", Date.new(2024, 3, 1), Date.new(2029, 3, 1)]
].map do |doc_number, title, doc_type, issued_on, valid_until|
  NormativeDocument.find_or_create_by!(doc_number: doc_number) do |document|
    document.title = title
    document.doc_type = doc_type
    document.issued_on = issued_on
    document.valid_until = valid_until
  end
end

puts "Seeding equipment..."
models_by_type = {
  "GENERATOR" => ["N5183B", "SMB100B", "MG3694C", "GSS-30"],
  "AMPLIFIER" => ["8349B", "BBA150", "MPA-10", "УМ-8"],
  "SPECTRUM" => ["N9020B", "FSW26", "MS2830A", "С4-85"],
  "POWER_METER" => ["N1914A", "NRP2", "ML2438A", "М3-56"],
  "FREQ_COUNTER" => ["53230A", "FSWP", "MF2414B", "Ч3-85"],
  "ATTENUATOR" => ["8496B", "RSC-10", "MN-20", "Д3-33"],
  "COUPLER" => ["11636B", "RK-20", "DC-10", "НО-5"],
  "CALIBRATOR" => ["N432A", "SMB100B", "MG3694C", "К2-100"]
}

rng = Random.new(20_261_114)
departments_list = departments.values
users_for_responsibility = [engineer, metrologist]
equipment_list = []
inventory_counter = 0

models_by_type.each do |type_code, models|
  models.each_with_index do |model, model_index|
    inventory_counter += 1
    type = equipment_types.fetch(type_code)
    manufacturer = manufacturers[(inventory_counter - 1) % manufacturers.length]
    department = departments_list[(inventory_counter - 1) % departments_list.length]
    responsible_user = users_for_responsibility[(inventory_counter - 1) % users_for_responsibility.length]

    commissioned_on = Date.current - ((inventory_counter % 9) + 1).years
    last_verified_on =
      if inventory_counter % 11 == 0
        nil
      elsif inventory_counter % 6 == 0
        Date.current - 11.months
      elsif inventory_counter % 7 == 0
        Date.current - 13.months
      else
        Date.current - ((inventory_counter % 8) + 1).months
      end
    next_verification_on =
      if last_verified_on
        last_verified_on + 12.months
      else
        commissioned_on + 12.months
      end

    equipment = Equipment.find_or_create_by!(inventory_number: format("INV-%04d", inventory_counter)) do |record|
      record.serial_number = format("SN-%s-%04d", type_code, inventory_counter)
      record.model = model
      record.equipment_type = type
      record.manufacturer = manufacturer
      record.department = department
      record.responsible_user = responsible_user
      record.status =
        if inventory_counter % 17 == 0
          "decommissioned"
        elsif inventory_counter % 13 == 0
          "in_repair"
        else
          "in_service"
        end
      record.commissioned_on = commissioned_on
      record.verification_interval_months = 12
      record.last_verified_on = last_verified_on
      record.next_verification_on = next_verification_on
      record.location = "Лаборатория #{((model_index % 4) + 1)}"
      record.notes = "Демонстрационная запись реестра"
    end

    equipment_list << equipment
  end
end

puts "Seeding verification schedules..."
equipment_list.each_with_index do |equipment, index|
  next if equipment.decommissioned?
  next if equipment.next_verification_on.blank?

  VerificationSchedule.find_or_create_by!(
    equipment: equipment,
    planned_on: equipment.next_verification_on
  ) do |schedule|
    schedule.period_year = equipment.next_verification_on.year
    schedule.responsible_user = equipment.responsible_user
    schedule.normative_document = normative_documents[index % normative_documents.length]
    schedule.status = index % 4 == 0 ? "approved" : "planned"
    schedule.notes = "Плановая поверка по межповерочному интервалу"
  end
end

puts "Seeding completed verifications..."
equipment_list.each_with_index do |equipment, index|
  next if equipment.last_verified_on.blank?

  verification_status = index % 9 == 0 ? "failed" : "passed"
  performed_on = equipment.last_verified_on

  verification = Verification.find_or_create_by!(
    equipment: equipment,
    performed_on: performed_on
  ) do |record|
    document_sequence = DocumentCounter.next_value!(
      kind: "verification",
      year: performed_on.year
    )

    record.status = verification_status
    record.performed_by = index.even? ? engineer : metrologist
    record.completed_at = performed_on.to_time + 10.hours
    record.protocol_number = format("PR-%d-%06d", performed_on.year, document_sequence)
    if verification_status == "passed"
      record.certificate_number = format("SV-%d-%06d", performed_on.year, document_sequence)
      record.conclusion = "Оборудование пригодно к эксплуатации"
    else
      record.conclusion = "Оборудование не соответствует требованиям методики поверки"
    end
  end

  [
    ["Выходная мощность", "Вт", 10.0, 10.0, 0.5],
    ["Частота", "ГГц", 10.0, 10.0, 0.01],
    ["КСВН", "", 1.2, 1.2, 0.1]
  ].each_with_index do |(parameter_name, unit, reference_value, nominal_value, tolerance), result_index|
    failed_measurement = verification_status == "failed" && result_index.zero?
    measured_value = failed_measurement ? nominal_value + tolerance * 4 : nominal_value

    VerificationResult.find_or_create_by!(
      verification: verification,
      parameter_name: parameter_name
    ) do |result|
      result.unit = unit
      result.measured_value = measured_value
      result.reference_value = reference_value
      result.tolerance = tolerance
      result.passed = !failed_measurement
      result.measured_at = performed_on.to_time + 10.hours + result_index.minutes
      result.raw_payload = { source: "seed", channel: result_index + 1 }
    end
  end
end

puts "Seeding notifications..."
equipment_list.select { |item| !item.decommissioned? && item.overdue? }.first(3).each do |equipment|
  next if equipment.responsible_user.blank?

  Notification.find_or_create_by!(
    user: equipment.responsible_user,
    notifiable: equipment,
    kind: "overdue",
    due_on: equipment.next_verification_on
  ) do |notification|
    notification.message = "Просрочена поверка оборудования #{equipment.inventory_number} (#{equipment.model})"
  end
end

equipment_list.select { |item| !item.decommissioned? && item.due_soon? }.first(3).each do |equipment|
  next if equipment.responsible_user.blank?

  Notification.find_or_create_by!(
    user: equipment.responsible_user,
    notifiable: equipment,
    kind: "due_soon",
    due_on: equipment.next_verification_on
  ) do |notification|
    notification.message = "Приближается срок поверки оборудования #{equipment.inventory_number} (#{equipment.model})"
  end
end

puts "Seed completed:"
puts "  roles: #{Role.count}"
puts "  departments: #{Department.count}"
puts "  users: #{User.count}"
puts "  equipment types: #{EquipmentType.count}"
puts "  manufacturers: #{Manufacturer.count}"
puts "  normative documents: #{NormativeDocument.count}"
puts "  equipment: #{Equipment.count}"
puts "  verification schedules: #{VerificationSchedule.count}"
puts "  verifications: #{Verification.count}"
puts "  verification results: #{VerificationResult.count}"
puts "  notifications: #{Notification.count}"
puts "  demo accounts: admin@example.com / metrologist@example.com / engineer@example.com / customer@example.com (password123)"
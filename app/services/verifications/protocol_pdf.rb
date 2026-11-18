require "prawn/table"

module Verifications
  class ProtocolPdf
    FONT_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    BOLD_FONT_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

    def initialize(verification)
      @verification = verification
    end

    def render
      Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
        pdf.font_families.update(
          "DejaVu" => { normal: FONT_PATH, bold: BOLD_FONT_PATH }
        )
        pdf.font "DejaVu"

        pdf.text "ПРОТОКОЛ ПОВЕРКИ", size: 16, style: :bold, align: :center
        pdf.text "№ #{verification.protocol_number.presence || "—"}", size: 11, align: :center
        pdf.text "от #{format_date(verification.performed_on)}", size: 10, align: :center
        pdf.move_down 18

        render_equipment(pdf)
        render_results(pdf)
        render_conclusion(pdf)

        pdf.move_down 30
        pdf.text "Поверитель: #{verification.performed_by&.display_name || "—"}"
        pdf.move_down 18
        pdf.text "Подпись: ____________________", size: 10
      end.render
    end

    private

    attr_reader :verification

    def render_equipment(pdf)
      equipment = verification.equipment

      rows = [
        ["Инвентарный номер", equipment.inventory_number],
        ["Заводской номер", equipment.serial_number],
        ["Модель", equipment.model],
        ["Тип оборудования", equipment.equipment_type.name],
        ["Производитель", equipment.manufacturer.name],
        ["Подразделение", equipment.department.name]
      ]

      pdf.table(rows, width: pdf.bounds.width, cell_style: { size: 9, padding: 5 }) do
        columns(0).font_style = :bold
        columns(0).width = 170
      end

      pdf.move_down 16
    end

    def render_results(pdf)
      pdf.text "Результаты измерений", size: 12, style: :bold
      pdf.move_down 6

      header = ["Параметр", "Ед.", "Измерено", "Опорное", "Допуск", "Результат"]
      rows = verification.verification_results.map do |result|
        [
          result.parameter_name,
          result.unit.presence || "—",
          format_number(result.measured_value),
          format_number(result.reference_value),
          format_number(result.tolerance),
          result.passed? ? "Пригодно" : "Непригодно"
        ]
      end

      pdf.table([header] + rows, header: true, width: pdf.bounds.width,
                cell_style: { size: 8, padding: 4 }) do
        row(0).font_style = :bold
        row(0).background_color = "EEF2F8"
      end

      pdf.move_down 16
    end

    def render_conclusion(pdf)
      conclusion = verification.conclusion.presence ||
                   (verification.passed? ? "Оборудование пригодно к эксплуатации" : "Оборудование не соответствует требованиям")

      pdf.text "Заключение", size: 12, style: :bold
      pdf.text conclusion, size: 10
      pdf.move_down 8
      pdf.text "Свидетельство о поверке: #{verification.certificate_number.presence || "не выдавалось"}", size: 10
    end

    def format_date(date)
      date ? date.strftime("%d.%m.%Y") : "—"
    end

    def format_number(value)
      return "—" if value.nil?

      value.to_s("F")
    end
  end
end
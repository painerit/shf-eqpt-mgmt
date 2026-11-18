module ApplicationHelper
  def page_title(title)
    content_for(:title, "#{title} — #{t('app.title')}")
  end

  def human_date(value)
    value&.strftime("%d.%m.%Y") || "—"
  end

  def human_datetime(value)
    value&.strftime("%d.%m.%Y %H:%M") || "—"
  end

  def enum_label(model, attribute, value)
    return "—" if value.blank?

    I18n.t(
      "enums.#{model.model_name.i18n_key}.#{attribute}.#{value}",
      default: value.to_s.humanize
    )
  end

  def flash_class(type)
    {
      "notice" => "success",
      "success" => "success",
      "alert" => "danger",
      "error" => "danger"
    }.fetch(type.to_s, "info")
  end

  def status_badge_class(status)
    case status.to_s
    when "in_service", "passed", "approved", "completed"
      "badge badge--success"
    when "in_repair", "in_progress", "planned", "reserved"
      "badge badge--warning"
    when "decommissioned", "failed", "canceled"
      "badge badge--danger"
    else
      "badge badge--neutral"
    end
  end

  def nav_link_class(path)
    current_page?(path) ? "nav-link nav-link--active" : "nav-link"
  end

  def unread_notifications_count
    current_user ? current_user.notifications.unread.count : 0
  end

  def user_initials(user)
    user.full_name.to_s.split.first(2).map { |part| part.first }.join.upcase
  end

  def days_label(count)
    t("common.days", count: count)
  end

  def notification_kind_label(kind)
    {
      "overdue" => "Просрочено",
      "due_soon" => "Скоро поверка",
      "verification_completed" => "Поверка завершена"
    }.fetch(kind.to_s, kind.to_s.humanize)
  end
end
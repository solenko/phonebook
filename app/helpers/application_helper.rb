module ApplicationHelper

  def sortable_header(field, title = nil)
    title ||= field.titleize
    css_class = "sortable "
    css_class << "current" if field == order_field
    direction = field.to_s == order_field && order_direction == "asc" ? "desc" : "asc"
    link_to title, {:order_field  => field, :direction => direction}, {:class => css_class}
  end

end

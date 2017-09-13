class SingleAttributeRenderer < Hyrax::Renderers::AttributeRenderer

  # Single valued properties will return an array like so [''].
  #  Only render the field if the values array contains an actual value.
  def render
    markup = ''
    return markup if values.collect { | v | v.blank? }.include? true && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute #{field}")
    Array(values).each do |value|
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end

end
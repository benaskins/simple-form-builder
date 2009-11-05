module Simplicity

  module SimpleFormHelper
    def simple_form_for(record_or_name_or_array, *args, &proc)
      options = args.extract_options!
      # Remove any nils if we received an array, this allows for common forms to be built
      # that can be used for both edit and new actions but that don't require the edit action
      # to be nested within a parent resource
      record_or_name_or_array.reject! {|a| a.nil? } if record_or_name_or_array.is_a? Array 
      # Now build the form
      form_for(record_or_name_or_array, *(args << options.merge(:builder => SimpleFormBuilder)), &proc)
    end
    
    def simple_fields_for(record_or_name_or_array, *args, &proc)
      options = args.extract_options!
      fields_for(record_or_name_or_array, *(args << options.merge(:builder => SimpleFormBuilder)), &proc)
    end    
  end

  class SimpleFormBuilder < ActionView::Helpers::FormBuilder

    def initialize(*args)
      @tab_index = 0
      super
    end

    def date_select(method, options={})
      list_item(label(method, options) + super, :class => "dates")
    end

    def time_select(method, options={})
      list_item(label(method, options) + super, :class => "dates")
    end

    def text_field(method, options={})
      labelled_field(method, options, super)
    end

    def password_field(method, options={})
      labelled_field(method, options, super)
    end

    def text_area(method, options={})
      labelled_field(method, options, super)
    end

    def check_box(method, options={}, checked_value="1", unchecked_value="0")
      list_item(super + label(method, options.merge(:no_colon => true)), :class => "checkbox")
    end

    def radio_button(method, tag_value, options={})
      super + radio_label(method, tag_value, options)
    end

    def select(method, choices, options={}, html_options={})
      labelled_field(method, options, super)
    end

    def collection_select(method, collection, value_method=:id, text_method=:name, options={}, html_options={})
      list_item(label(method, options) + super)
    end

    def country_select(method, priority_countries=nil, options={}, html_options={})
      labelled_field(method, options, super)
    end

    def time_zone_select(method, priority_zones=nil, options={}, html_options={})
      labelled_field(method, options, super)
    end

    def file_field(method, options={})
      labelled_field(method, options, super)
    end

    def title(text)
      @template.content_tag(:h3, text)
    end
    
    def hint(text)
      @template.content_tag(:p, text)
    end

    def fieldset(options={}, &block)
      @template.concat @template.tag(:fieldset, options.merge(:class => "set"), true)
      @template.concat @template.tag(:ol, nil, true)

      yield

      @template.concat "</ol></fieldset>"
    end

    def buttons(&block)
      @template.concat @template.tag(:fieldset, nil, true)
      @template.concat @template.tag(:ol, nil, true)

      yield

      @template.concat "</ol></fieldset>"
    end

    def button(options={})
      prefix = @object.respond_to?(:new_record?) && @object.new_record? ? "Create" : "Save"
      label = options[:label] || "#{prefix @object_name.humanize}"
      button_content = options[:img] ? @template.content_tag(:img, nil, :src => options[:img], :alt => label) + label : label
      list_item(@template.content_tag(:button, button_content, :type => "submit"))
    end
    
    def inner_fieldset(legend=nil, &block)
      @template.concat @template.tag(:li, nil, true)
      @template.concat @template.tag(:fieldset, nil, true)
      @template.concat @template.content_tag(:h3, "#{legend}:") unless legend.nil?
      @template.concat @template.tag(:ol, nil, true)

      yield

      @template.concat "</ol></fieldset></li>"
    end

    def submit(value="Save Changes", options={})
      @template.content_tag(:fieldset, super, :class => "button")
    end

    def fieldgroup(options={}, &block)
      @already_grouping = true
      @template.concat @template.tag(:li, options, true)
      yield
      @template.concat "</li>"
      @already_grouping = false
    end

    def labelled_field(method, options, markup)
      if @already_grouping
        markup + label(method, options)
      else
        list_item(label(method, options) + markup)
      end
    end

    def reversed_labelled_field(method, options, markup)
      if @already_grouping
        markup + label(method, options)
      else
        list_item(markup + label(method, options))
      end
    end

    private

    def list_item(markup, options={})
      @template.content_tag(:li, markup, options)
    end

    def label(method, options={})
      text = options.delete(:label) || (@already_grouping ? method.to_s.titleize.upcase : method.to_s.titleize)
      text += ":" unless options.delete(:no_colon)
      dom_class = options.delete(:label_class) || method
      ActionView::Helpers::InstanceTag.new(
        object_name, method, self, options.delete(:object)
      ).to_label_tag(text, :class => dom_class)
    end

    def radio_label(method, value, options={})
      @template.content_tag :label,
        value.humanize,
        options.merge(:for => radio_button_id(method, value, options))
    end

    def radio_button_id(method, value, options)
      pretty_value = value.to_s.gsub(/\s/, "_").gsub(/\W/, "").downcase

      options[:id] || defined?(@auto_index) ?
        "#{object_name}_#{@auto_index}_#{method}_#{pretty_value}" :
        "#{object_name}_#{method}_#{pretty_value}"
    end
    
    def cancel_link(options_or_url)
      if options_or_url.is_a? Hash
        cancel_url   = options_or_url.delete(:url)
        dom_class    = options_or_url.delete(:class)
        cancel_label = options_or_url.delete(:label)
      else
        cancel_url   = options_or_url 
        dom_class    = nil
        cancel_label = nil
      end
      @template.link_to cancel_label || "Cancel", cancel_url || :back, :class => "cancel #{dom_class}"
    end
  end
    
end
# DOC:
# We use Helper Methods for tree building,
# because it's faster than View Templates and Partials

# SECURITY note
# Prepare your data on server side for rendering
# or use h.html_escape(node.content)
# for escape potentially dangerous content
module AttachedFilesListHelper
  module Render 
    class << self
      attr_accessor :h, :options

      def render_node(h, options)
        @h, @options = h, options
        @node = options[:node]

        "
          <li data-node-id='#{ @node.id }'>
            <div class='item'>
              <i class='handle'></i>
              <div class='preview_pic'>#{build_preview_pic}</div>
              #{ show_link }
              #{ controls }
            </div>
            #{ children }
          </li>
        "
      end

      def build_preview_pic
        if @node.is_image?
          src = @node.url(:preview)
          url = @node.url(:base)
          "<a href='#{url}'><img src='#{src}'></a>"
        else
          klass = @node.content_type_class
          url = @node.url
          "<a href='#{url}'><i class='#{klass}'></i></a>"
        end
      end

      def show_link
        node = options[:node]
        ns   = options[:namespace]
        title_field = options[:title]
        url = @node.is_image? ? @node.url(:base) : @node.url
        "<h4>#{ h.link_to(node.send(title_field), url) }</h4>"
      end

      def controls
        node = options[:node]

        edit_path = h.url_for(:controller => options[:klass].pluralize, :action => :edit, :id => node)
        show_path = h.url_for(:controller => options[:klass].pluralize, :action => :show, :id => node)

        #{ h.link_to '', edit_path, :class => :edit }

        "
          <div class='controls'>
            #{ h.link_to '', show_path, :class => :delete, :method => :delete, :data => { :confirm => 'Are you sure?' } }
          </div>
        "
      end

      def children
        unless options[:children].blank?
          "<ol class='nested_set'>#{ options[:children] }</ol>"
        end
      end

    end
  end
end
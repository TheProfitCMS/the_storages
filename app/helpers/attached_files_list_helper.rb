# encoding: UTF-8

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
          <li data-node-id='#{ @node.id }' id='attached_file_#{ @node.id }' >
            <div class='item'>
              <table class='table table-bordered'>
                <tr>
                  <td class='left_controls warning'>
                    <i class='handle'></i>

                  </td>

                  <td class='preview_pic'>
                    #{ build_preview_pic }
                  </td>

                  <td class='main_block'>
                    #{ show_link }
                    #{ url_input }
                    #{ show_size }
                  </td>

                  <td class='right_controls danger'>
                    #{ controls }
                  </td>
                </tr>
              </table>
            </div>

            #{ children }
          </li>
        "
      end

      def current_host
        h.request.protocol + h.request.host_with_port
      end

      def url_input
        opts = {nocache: false, timestamp: false}
        url = @node.is_image? ? @node.url(:base, opts) : @node.url(:original, opts)
        "<p>
          <label>URL</label>
          <input class='form-control' type='text' value='#{ current_host + url }'>
        </p>"
      end

      def show_size
        "<p>#{@node.mb_size}</p>"
      end

      # def watermark_switch
      #   if @node.is_image?
      #     link = if @node.watermark
      #       h.link_to "Отключить", h.watermark_switch_attached_file_path(@node), method: :patch
      #     else
      #       h.link_to "Включить", h.watermark_switch_attached_file_path(@node), method: :patch
      #     end

      #     "<p>Водный знак: #{ link }</p>"
      #   end
      # end

      # def rotate_links
      #   if @node.is_image?
      #     left  = h.link_to '', h.rotate_left_url(@node),  method: :patch, class: :left
      #     right = h.link_to '', h.rotate_right_url(@node), method: :patch, class: :right
      #     "<div class='rotate'>#{left} #{right}</div>"
      #   end
      # end

      def build_preview_pic
        if @node.is_image?
          src = @node.url(:preview)
          url = @node.url(:base)
          "<a href='#{url}'><img src='#{ src }'></a>"
        else
          klass = @node.file_css_class
          url = @node.url
          "<a href='#{url}'><i class='#{ klass }'></i></a>"
        end
      end

      def show_link
        node = options[:node]
        ns   = options[:namespace]
        title_field = options[:title]
        title = node.send(title_field)
        url = @node.is_image? ? @node.url(:base) : @node.url
        "<p>#{ h.link_to(title, url)}</p>"
      end

      def controls
        node = options[:node]

        edit_path = h.url_for(:controller => options[:klass].pluralize, :action => :edit, :id => node)
        show_path = h.url_for(:controller => options[:klass].pluralize, :action => :show, :id => node)

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

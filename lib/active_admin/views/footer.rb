module ActiveAdmin
  module Views
    class Footer < Component

      private

      def powered_by_message
        para I18n.t('active_admin.powered_by', active_admin: link_to("Active Admin", "http://www.activeadmin.info"), version: ActiveAdmin::VERSION).html_safe

        if MyApplicationName::Application.assets.find_asset("ui/#{params[:controller]}.js")
          render text: javascript_include_tag("aa_charts")
          render text: javascript_include_tag("ui/#{params[:controller]}")
        end
      end

    end
  end
end
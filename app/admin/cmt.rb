ActiveAdmin.register_page "CMT" do

  menu priority: 1, label: "Cognos TBS Monitoring Tool" # proc{ I18n.t("active_admin.cmt") }
  content title: "Cognos TBS Monitoring Tool" do #proc{ I18n.t("active_admin.cmt") } do

    columns do
      column do
        render "cmt"
      end
    end
  end # content
end

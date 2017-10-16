ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  content title: proc{ I18n.t("active_admin.dashboard") } do
=begin
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
=end
    # Here is an example of a simple dashboard with columns and panels.
    columns do
      column do
        panel "Last 5 Jobs that ran with error" do
          ul do
            tiv_errors = TivoliHistory.where(status: "ERR") #.where("start_datetime > ")
            tiv_last_errors = tiv_errors.order("start_datetime DESC").first(5)
            tiv_last_errors.map do |t|
              li "#{t.workstation}##{t.stream}.#{t.job} --> #{t.start_datetime.strftime("%m/%d/%y %H:%M")} -- #{t.end_datetime.strftime("%m/%d/%y %H:%M")}" # - #{t.log}"
            end
          div link_to("See all", admin_tivoli_histories_path + "?utf8=✓&q[status_equals]=ERR&commit=Filter&order=id_desc") + " - Total errors: " + tiv_errors.count.to_s
          div pie_chart tiv_errors.group(:workstation).count
          end
        end
      end
      column do
        panel "Statistics" do
          #para "Some Graphs here"
          ul do
            li "Quantity of Tivoli Jobs: "+ TivoliJob.count.to_s 
            para link_to("See all", admin_tivoli_jobs_path)
            li "Quantity of Tivoli Jobs that run on B03ACIAPP017: "+ TivoliJob.where(workstation: "B03ACIAPP017").count.to_s
            para link_to("See all", admin_tivoli_jobs_path + "?utf8=✓&q[workstation_equals]=B03ACIAPP017&commit=Filter&order=id_desc")
            li "Quantity of Tivoli Jobs that run on B03ACIAPP018: "+ TivoliJob.where(workstation: "B03ACIAPP018").count.to_s
            para link_to("See all", admin_tivoli_jobs_path + "?utf8=✓&q[workstation_equals]=B03ACIAPP018&commit=Filter&order=id_desc")
            li "Quantity of Tivoli Jobs that run on B03ACIAPP019: "+ TivoliJob.where(workstation: "B03ACIAPP019").count.to_s
            para link_to("See all", admin_tivoli_jobs_path + "?utf8=✓&q[workstation_equals]=B03ACIAPP019&commit=Filter&order=id_desc")
            li "Quantity of Tivoli Jobs NEW that must attention: "+ TivoliJob.where("script IS NULL OR user_id_run IS NULL OR dependency IS NULL").count.to_s
            para link_to("See all", admin_tivoli_jobs_path + "?order=script_desc&q[schedule_equals]=+&utf8=✓")
          #column_chart [["2016-01-01", 30], ["2016-02-01", 54]], stacked: true, library: {colors: ["#D80A5B", "#21C8A9", "#F39C12", "#A4C400"]}
            para " - "
          end
        end
      end
    end

      columns do
       column do
          panel "Last 5 jobs with longest run" do
           ul do
            tivs_max_time_run = TivoliHistory.where("status = ? AND start_datetime BETWEEN ? AND ? ", "AOK", (Date.today - 60.days), Date.today).order(:elapsed_time).limit(10)
            tivs_max_time_run = tivs_max_time_run.order("elapsed_time DESC").first(5)
            tivs_max_time_run.map do |t|  
              li "#{t.workstation}##{t.stream}.#{t.job} --> #{t.start_datetime.strftime("Start: %m/%d/%y %H:%M")} | #{t.end_datetime.strftime("End: %m/%d/%y %H:%M")} | #{elapsed_time.to_datetime.strftime("Elapsed time: %H:%M")}"  # - #{t.log}"
            end
          end
        end
      end

  end # content
end

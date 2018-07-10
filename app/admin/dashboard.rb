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
            tiv_errors = JobHistory.where(status: "ERR")
            tiv_last_errors = tiv_errors.order("start_datetime DESC").first(5)
            tiv_last_errors.map do |t|
              li link_to("#{t.workstation}##{t.stream}.#{t.job_name}", admin_jobs_path + "?utf8=✓&q[workstation_equals]=#{t.workstation}&q[stream_equals]=#{t.stream}&q[job_name_equals]=#{t.job_name}") + ": #{t.start_datetime.strftime("%m/%d/%y %H:%M")} - #{t.elapsed_time}"
            end
            div link_to("See all", admin_job_histories_path + "?utf8=✓&q[status_equals]=ERR&commit=Filter&order=id_desc") + " - Total errors: " + tiv_errors.count.to_s
            div pie_chart tiv_errors.group(:workstation).count
          end
        end
      end
      column do
        panel "Quantity of Job by Application/Workstation" do
          @tivoli_type = JobType.where(job_type: "Tivoli").first
          @ds_type = JobType.where(job_type: "Datastage").first
          ul do
            li do
              unless @tivoli_type.blank?
                span "Quantity of Tivoli Jobs: "+ Job.where(job_type_id: @tivoli_type.id).count.to_s + " -> "
                span link_to("See all", admin_jobs_path + "utf8=✓&q[job_type_id_eq]=#{@tivoli_type.id}&commit=Filter&order=id_desc")
              else
                span "No Tivoli jobs to display"
              end
            end             
            li do
              unless @tivoli_type.blank?
                span "Quantity of Datastage Jobs: "+ Job.where(job_type_id: @ds_type.id).count.to_s + " -> "
                span link_to("See all", admin_jobs_path + "?utf8=✓&q[job_type_id_equals]=#{@ds_type.id}&commit=Filter&order=id_desc")
              else
                span "No Datastage jobs to display"
              end 
            end 
=begin
            li do
              span "Quantity of Tivoli Jobs NEW that missing details: "+ Job.where("script IS NULL OR user_id_run IS NULL OR dependency IS NULL").where(job_type_id: @tivoli_type_id).count.to_s  + " -> "
              span link_to("See all", admin_jobs_path + "?order=script_desc&q[job_type_id_equals]=#{@tivoli_type_id}&&commit=Filter&utf8=✓")
            end 
=end
          end 
          job_with_count_gouped = Job.group("UPPER(workstation)").count
          div pie_chart job_with_count_gouped unless job_with_count_gouped.blank?
        end 

        panel "Last 5 jobs with longest run" do
          ul do
            tivs_max_time_run = JobHistory.where("lower(job_name) NOT LIKE '%_loop' AND status = ? AND start_datetime BETWEEN ? AND ? ", "AOK", (Date.today - 60.days), Date.today).order("elapsed_time DESC").first(5)
            #tivs_max_time_run = tivs_max_time_run.order("elapsed_time DESC").first(5)
            unless tivs_max_time_run.blank?
              tivs_max_time_run.map do |t|  
                li link_to("#{t.workstation}##{t.stream}.#{t.job_name}", admin_jobs_path + "??utf8=✓&q[workstation_equals]=#{t.workstation}&q[stream_equals]=#{t.stream}&q[job_name_equals]=#{t.job_name}") + ": #{t.start_datetime.strftime("Start: %m/%d %H:%M")} | #{t.elapsed_time.to_datetime.strftime("Elapsed time: %H:%M")}"
              end
              div link_to("See all", admin_job_histories_path + "?order=elapsed_time_desc")
              @jobs_array = []
              tivs_max_time_run.each do |tmtr|
                @job_item_series = []
                job_item_history = JobHistory.where("workstation = ? AND stream = ? AND job_name = ?", tmtr.workstation, tmtr.stream, tmtr.job_name).order("start_datetime").limit(5)
                job_item_history.each do |jih|
                  @job_item_series << [ jih.start_datetime.strftime("%a %m/%d"), (jih.elapsed_time[0..1].to_i * 60 + jih.elapsed_time[3..4].to_i) ]
                end
                @jobs_array << {name: "#{tmtr.workstation}##{tmtr.stream}.#{tmtr.job_name}", data: @job_item_series}
              end
              div line_chart @jobs_array
            else
              span "No jobs"
            end
          end
        end
      end
    end

  end # content
end

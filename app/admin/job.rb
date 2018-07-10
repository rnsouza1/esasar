ActiveAdmin.register Job do
  permit_params :workstation, :stream, :job_name, :script, :user_id_run, :schedule, :server_run, :dependency, :stream_related, :job_type_id
  
  index do
    #selectable_column
    id_column
    #column :server_run
    column "Job Name" do |j|
      link_to j.fulljobname, admin_job_url(j), title: "Check job details and graphic performance"
    end
    #column :workstation
    #column :stream
    #column :job
    #column "User ID" do |u|
    #  u.user_id_run
    #end
    column :user_id_run
    #column :schedule
    column :script
    #column :dependency
    column "" do |j|
      link_to fa_icon('book 2x'), admin_job_histories_path + "?utf8=%E2%9C%93&q%5Bworkstation_equals%5D=#{j.workstation}&q%5Bjob_name_equals%5D=#{j.job_name}&commit=Filter&order=id_desc", title: "Check job history" 
    end
    actions
  end

  filter :server_run
  filter :workstation
  filter :stream
  filter :job_name
  filter :user_id_run
  filter :schedule
  filter :script
  filter :dependency
  filter :stream_related
  filter :job_type, as: :select, collection: JobType.pluck(:job_type, :id) 

  form do |f|
    panel "Job Details" do

      f.inputs  do
        f.input :server_run
        f.input :workstation
        f.input :stream
        f.input :job_name
        f.input :user_id_run
        f.input :schedule
        f.input :script
        f.input :dependency
        f.input :stream_related        
        f.input :job_type, as: :select, collection: JobType.pluck(:job_type, :id) 
      end
      f.actions
    end
  end  

  show do
    #h3 "Tivoli Job - #{tivoli_job.workstation}##{tivoli_job.stream}.#{tivoli_job.job}"
    columns do
      column do

        attributes_table do
          row :server_run
          row :workstation
          row :stream
          row :job_name
          row :user_id_run
          row :schedule
          row :script
          row "Dependency" do |c|
            c.dependency.gsub(",", ",<br>").html_safe unless c.dependency.blank?
          end
          row :stream_related        
          row :job_type do |jt|
            jt.job_type.job_type
          end
        end
      end  

      column do
        panel "Job Performance for: #{job.workstation}##{job.stream}.#{job.job_name}" do
          div :style => "padding: 0 15px;" do
            span job.job_histories.count.to_s + " jobs in history, "
            span link_to ("check here " + fa_icon('book 1x')).html_safe, admin_job_histories_path + "?utf8=%E2%9C%93&q%5Bworkstation_equals%5D=#{job.workstation}&q%5Bjob_name_equals%5D=#{job.job_name}&commit=Filter&order=id_desc", title: "Check job history"
          end
          jh = job.job_histories.order(:start_datetime)
          canvas "myChart", :style => "padding: 0 5px 0 15px;", :id => "myChart", "data-dates" => "#{ jh.collect{|x| x.start_datetime.strftime('%m/%d')} }", "data-elapsed_time" => "#{ jh.order(:start_datetime).collect{|x| x.elapsed_time[3..4]} }"
        end
      end
    end
    para "&nbsp".html_safe
    active_admin_comments 
  end

end

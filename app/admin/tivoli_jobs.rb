ActiveAdmin.register TivoliJob do
  permit_params :workstation, :stream, :job, :script, :user_id_run, :schedule, :server_run, :dependency, :stream_related
  
  index do
    #selectable_column
    #id_column
    #column :server_run
    column "Job Name" do |j|
      link_to j.fulljobname, admin_tivoli_job_url(j), title: "Check job details and graphic performance"
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
      link_to fa_icon('book 2x'), admin_tivoli_histories_path + "?utf8=%E2%9C%93&q%5Bworkstation_equals%5D=#{j.workstation}&q%5Bjob_equals%5D=#{j.job}&commit=Filter&order=id_desc", title: "Check job history" 
    end
    actions
  end

  filter :server_run
  filter :workstation
  filter :stream
  filter :job
  filter :user_id_run
  filter :schedule
  filter :script
  filter :dependency
  filter :stream_related

  form do |f|
    panel "Job Details" do

      f.inputs  do
        f.input :server_run
        f.input :workstation
        f.input :stream
        f.input :job
        f.input :user_id_run
        f.input :schedule
        f.input :script
        f.input :dependency
        f.input :stream_related        
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
          row :job
          row :user_id_run
          row :schedule
          row :script
          row "Dependency" do |c|
            c.dependency.gsub(",", ",<br>").html_safe unless c.dependency.blank?
          end
          row :stream_related        
        end
      end  

      column do
        panel "Job Performance for: #{tivoli_job.workstation}##{tivoli_job.stream}.#{tivoli_job.job}" do
          div :style => "padding: 0 15px;" do
            span tivoli_job.tivoli_histories.count.to_s + " jobs in history, "
            span link_to ("check here " + fa_icon('book 1x')).html_safe, admin_tivoli_histories_path + "?utf8=%E2%9C%93&q%5Bworkstation_equals%5D=#{tivoli_job.workstation}&q%5Bjob_equals%5D=#{tivoli_job.job}&commit=Filter&order=id_desc", title: "Check job history"
          end
          canvas "myChart", :style => "padding: 0 5px 0 15px;", :id => "myChart", "data-dates" => "#{ tivoli_job.tivoli_histories.order(:start_datetime).collect{|x| x.start_datetime.strftime('%m/%d')} }", "data-elapsed_time" => "#{ tivoli_job.tivoli_histories.order(:start_datetime).collect{|x| x.elapsed_time[3..4]} }"
        end
      end
    end
    para "&nbsp".html_safe
    active_admin_comments 
  end

end

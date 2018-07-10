ActiveAdmin.register JobHistory do
  menu label: "History"
  permit_params :status, :start_datetime, :end_datetime, :workstation, :stream, :job_name, :server_run, :log, :elapsed_time
  
  index do
    #column_chart [["2017-07-01", 30], ["2017-07-05", 54]], stacked: true, library: {colors: ["#D80A5B", "#21C8A9", "#F39C12", "#A4C400"]} 
    
    #id_column
    selectable_column
    column :status
    column :start_datetime
    column :elapsed_time
    column :workstation
    column :stream
    column :job_name
#    column "job" do |j|
#      link_to j.job, admin_job_url(j.job_id), title: "Check job details and graphic performance"
#    end
    #column :server_run
    #column :log
    #column :created_at
    actions
  end

  filter :status
  filter :elapsed_time
  filter :start_datetime
  filter :end_datetime
  filter :workstation
  filter :stream
  filter :job_name
  filter :server_run
  filter :log
  filter :job_type, as: :select, collection: JobType.pluck(:job_type, :id) 
  filter :created_at

  form do |f|
    f.inputs "Job History Details" do
      f.input :status
      f.input :elapsed_time
      f.input :start_datetime
      f.input :end_datetime
      f.input :workstation
      f.input :stream
      f.input :job_name
      f.input :server_run
      f.input :log
      f.input :job_type, as: :select, collection: JobType.pluck(:job_type, :id) 
    end
    f.actions
  end

end

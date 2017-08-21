ActiveAdmin.register TivoliHistory do
  permit_params :status, :start_datetime, :end_datetime, :workstation, :stream, :job, :server_run, :log, :elapsed_time
  
  index do
    #column_chart [["2017-07-01", 30], ["2017-07-05", 54]], stacked: true, library: {colors: ["#D80A5B", "#21C8A9", "#F39C12", "#A4C400"]} 
    
    #id_column
    selectable_column
    column :status
    column :start_datetime
    column :elapsed_time
    column :workstation
    column :stream
    column :job
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
  filter :job
  filter :server_run
  filter :log
  filter :created_at

  form do |f|
    f.inputs "Tivoli Hitory Details" do
      f.input :status
      f.input :elapsed_time
      f.input :start_datetime
      f.input :end_datetime
      f.input :workstation
      f.input :stream
      f.input :job
      f.input :server_run
      f.input :log
    end
    f.actions
  end

end

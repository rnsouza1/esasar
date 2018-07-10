ActiveAdmin.register JobType do
  menu label: "Types"
  permit_params :job_type, :description
  
  index do
    #column_chart [["2017-07-01", 30], ["2017-07-05", 54]], stacked: true, library: {colors: ["#D80A5B", "#21C8A9", "#F39C12", "#A4C400"]} 
    
    #id_column
    selectable_column
    column :job_type
    column :description
    actions
  end

  filter :job_type
  filter :description

  form do |f|
    f.inputs "Job History Details" do
      f.input :job_type
      f.input :description
    end
    f.actions
  end

end

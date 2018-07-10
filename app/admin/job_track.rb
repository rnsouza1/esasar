=begin
ActiveAdmin.register JobTrack do
  menu label: "Tracks"
  permit_params :title, :job_id, :description
  
  index do 
    selectable_column
    id_column
    column :title
    column :job do |j|
      j.job.fulljobname
    end
    column :description
    actions
  end

  filter :title
  filter :job #, as: :select, collection: Job.pluck({:stream, }, :id) 
  filter :description

  form do |f|
    f.inputs "Job Tracks" do
      f.input :title
      f.input :job #, as: :select, collection: Job.pluck(:fulljobname, :id) 
      f.input :description
    end
    f.actions
  end

end
=end
ActiveAdmin.register_page "Live Run" do

  menu priority: 1, label: "Live Run"
  content title: "Live Run" do
=begin
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
=end
    @chart = fa_icon('pie-chart 1x')
    columns id: "liverun" do
      column do
        panel "Tivoli Job live Run 017" do
          @workstations = ["B03ACIAPP017.ahe.boulder.ibm.com"] 
          @workstations.each do |workstation|
            File.readlines(File.join(Rails.public_path, ('live_tiv_data_'+ workstation +'.txt'))).last(10).each do |tiv| #.collect{|c| c.gsub!("\t\t", "").gsub!("\n", "").gsub("\t", " - ")[0..100]}.each do |tiv|
              columns style: "font-size: 10px" do
                line_splitted = tiv.split(" ")
                case line_splitted[0][0..2]
                when "AOK"
                  @icon = "check"
                  @style_color = "color: green"
                when "ERR"
                  @icon = "close"
                  @style_color = "color: red"
                when "RUN"
                  @icon = "play-circle"
                  if line_splitted[6].split("m")[0].split("h")[0].to_i > 1 || line_splitted[6].split("m")[0].split("h")[1].to_i > 15
                    @style_color = "color: darkorange"
                  else 
                    @style_color = "color: black"
                  end
                end
                column class: "text", style: "" do
                  if @icon == "check" || @icon == "play-circle"
                    span do 
                      workstation_and_stream_job = line_splitted[7].split("#")
                      workstation   = workstation_and_stream_job[0]
                      stream        = workstation_and_stream_job[1].split(".")[0]
                      job           = workstation_and_stream_job[1].split(".")[1]
                      tivoli_job    = TivoliJob.where(workstation: workstation, stream: stream, job: job).first
                      unless tivoli_job.blank? 
                        job_histories = tivoli_job.tivoli_histories.where.not(status: "ERR").order(:start_datetime).last(10)
                        dates         = job_histories.collect{|x| x.start_datetime.strftime('%m/%d')}
                        elapsed_times = job_histories.collect{|x| x.elapsed_time[3..4]} 
                        link_to @chart.html_safe, "#", "data-dates" => "#{ dates }", "data-elapsed_time" => "#{ elapsed_times }", "data-job_name" => "#{line_splitted[7]}", "data-toggle" => "modal", "data-target" => "#modChart"
                      end
                    end
                  end
                  span (fa_icon(@icon+' 1x') +" "+ line_splitted[7]).html_safe, style: @style_color, title: line_splitted[8]
                end
                column do
                  span line_splitted[1], style: @style_color
                end
                column do
                  span line_splitted[2], style: @style_color
                end
                column do
                  span line_splitted[5], style: @style_color #line_splitted[4]+" - "+line_splitted[5], style: @style_color
                end
                column do
                  span line_splitted[6], style: @style_color
                end

              end
            end
          end
        end
      end
      column do
        panel "Tivoli Job live Run 018" do
          @workstations = ["B03ACIAPP018.ahe.boulder.ibm.com"] 
          @workstations.each do |workstation|
            File.readlines(File.join(Rails.public_path, ('live_tiv_data_'+ workstation +'.txt'))).last(10).each do |tiv| #.collect{|c| c.gsub!("\t\t", "").gsub!("\n", "").gsub("\t", " - ")[0..100]}.each do |tiv|
              columns style: "font-size: 10px" do
                line_splitted = tiv.split(" ")
                case line_splitted[0][0..2]
                when "AOK"
                  @icon = "check"
                  @style_color = "color: green"
                when "ERR"
                  @icon = "close"
                  @style_color = "color: red"
                when "RUN"
                  @icon = "play-circle"
                    if line_splitted[6].split("m")[0].split("h")[0].to_i > 1 || line_splitted[6].split("m")[0].split("h")[1].to_i > 15
                    @style_color = "color: darkorange"
                  else 
                    @style_color = "color: black"
                  end
                end
                column class: "text", style: "" do
                  if @icon == "check" || @icon == "play-circle"
                    span do 
                      workstation_and_stream_job = line_splitted[7].split("#")
                      workstation   = workstation_and_stream_job[0]
                      stream        = workstation_and_stream_job[1].split(".")[0]
                      job           = workstation_and_stream_job[1].split(".")[1]
                      tivoli_job    = TivoliJob.where(workstation: workstation, stream: stream, job: job).first
                      unless tivoli_job.blank? 
                        job_histories = tivoli_job.tivoli_histories.where.not(status: "ERR").order(:start_datetime).last(10)
                        dates         = job_histories.collect{|x| x.start_datetime.strftime('%m/%d')}
                        elapsed_times = job_histories.collect{|x| x.elapsed_time[3..4]} 
                        link_to @chart.html_safe, "#", "data-dates" => "#{ dates }", "data-elapsed_time" => "#{ elapsed_times }", "data-job_name" => "#{line_splitted[7]}", "data-toggle" => "modal", "data-target" => "#modChart"
                      end
                    end
                  end
                  span (fa_icon(@icon+' 1x') +" "+ line_splitted[7]).html_safe, style: @style_color, title: line_splitted[8]
                end
                column do
                  span line_splitted[1], style: @style_color
                end
                column do
                  span line_splitted[2], style: @style_color
                end
                column do
                  span line_splitted[5], style: @style_color #line_splitted[4]+" - "+line_splitted[5], style: @style_color
                end
                column do
                  span line_splitted[6], style: @style_color
                end

              end
            end
          end
        end
      end
    end

    columns id: "liverun", style:"margin: 10px 0" do
      column do
        panel "Tivoli Job live Run 019" do
          @workstations = ["B03ACIAPP019.ahe.boulder.ibm.com"] 
          @workstations.each do |workstation|
            File.readlines(File.join(Rails.public_path, ('live_tiv_data_'+ workstation +'.txt'))).last(10).each do |tiv| #.collect{|c| c.gsub!("\t\t", "").gsub!("\n", "").gsub("\t", " - ")[0..100]}.each do |tiv|
              columns style: "font-size: 10px; backgorund-color: white;" do
                line_splitted = tiv.split(" ")
                case line_splitted[0][0..2]
                when "AOK"
                  @icon = "check"
                  @style_color = "color: green"
                when "ERR"
                  @icon = "close"
                  @style_color = "color: red"
                when "RUN"
                  @icon = "play-circle"
                  if line_splitted[6].split("m")[0].split("h")[0].to_i > 1 || line_splitted[6].split("m")[0].split("h")[1].to_i > 15
                    @style_color = "color: darkorange"
                  else 
                    @style_color = "color: black"
                  end
                end
                column class: "text", style: "" do
                  if @icon == "check" || @icon == "play-circle"
                    span do 
                      workstation_and_stream_job = line_splitted[7].split("#")
                      workstation   = workstation_and_stream_job[0]
                      stream        = workstation_and_stream_job[1].split(".")[0]
                      job           = workstation_and_stream_job[1].split(".")[1]
                      tivoli_job    = TivoliJob.where(workstation: workstation, stream: stream, job: job).first
                      unless tivoli_job.blank? 
                        job_histories = tivoli_job.tivoli_histories.where.not(status: "ERR").order(:start_datetime).last(10)
                        dates         = job_histories.collect{|x| x.start_datetime.strftime('%m/%d')}
                        elapsed_times = job_histories.collect{|x| x.elapsed_time[3..4]} 
                        link_to @chart.html_safe, "#", "data-dates" => "#{ dates }", "data-elapsed_time" => "#{ elapsed_times }", "data-job_name" => "#{line_splitted[7]}", "data-toggle" => "modal", "data-target" => "#modChart"
                      end
                    end
                  end
                  span (fa_icon(@icon+' 1x') +" "+ line_splitted[7]).html_safe, style: @style_color, title: line_splitted[8]
                end
                column do
                  span line_splitted[1], style: @style_color
                end
                column do
                  span line_splitted[2], style: @style_color
                end
                column do
                  span line_splitted[5], style: @style_color #line_splitted[4]+" - "+line_splitted[5], style: @style_color
                end
                column do
                  span line_splitted[6], style: @style_color
                end

              end
            end
          end
        end
      end
      column do
        panel "Datastage Job live Run" do
          File.readlines(File.join(Rails.public_path, 'live_dsd_data.txt')).collect{|c| c.gsub!("\t\t", "").gsub!("\n", "").gsub("\t", " - ")[0..100]}.each do |dsd|
            columns style: "font-size: 10px; backgorund-color: white;" do
              line_splitted = dsd.split(" ")
              @icon = "play-circle"
              @style_color = "color: black"
              column class: "text", style: "" do
                span (fa_icon(@icon+' 1x') +" "+ line_splitted[4]).html_safe, style: @style_color
              end
              column do
                span line_splitted[2], style: @style_color
              end
            end
          end
        end
      end

    end
=begin
    div style: "display:none" do
      div id: "data" do
        (canvas "jobChart", :style => "padding: 0 5px 0 15px; max-width:600px;", :id => "jobChart").html_safe  
      end
    end
=end
    columns do
      column do
        div class: "modal fade", id: "modChart", tabindex: "-1", role: "dialog", "aria-labelledby" => "exampleModalLabel", "aria-hidden" => "true" do
          div class: "modal-dialog" do
            div class: "modal-content" do
              div class: "modal-header" do
                div class: "modal-body" do
                  #canvas id: "canvas", width: "568", height: "300"
                  (canvas "jobChart", :style => "padding: 0 5px 0 15px; max-width:600px;", :id => "jobChart").html_safe  
                end
              end
            end
          end
        end
      end
    end

  end # content

  


end

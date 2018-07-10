ActiveAdmin.register_page "Live Run" do

  menu priority: 1, label: "Live Run"
  content title: "Live Run" do
=begin
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
name        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
=end
    @chart_icon    = fa_icon('pie-chart 1x')
    @log_icon = fa_icon('file-text-o 1x')
    columns id: "liverun" do

      column style: "display: block; width: 100%" do 
        @workstations = Workstation.all.order(:id)
        @workstations.each do |w|
          @w = w
          panel  "Tivoli Job #{w.name}", style: "display: block; width: 100%" do
            jobs_txt = $redis.get('live_tiv_data_'+w.url+'.'+w.port.to_s)
            if jobs_txt.blank? 
              columns style: "font-size: 10px; display: block; width: 100%" do
                column span: 5, class: "text", style: "" do
                  p "nothing to show!"
                end
              end
            else
              jobs_txt.split("\n").reverse.each do |tiv| #.collect{|c| c.gsub!("\t\t", "").gsub!("\n", "").gsub("\t", " - ")[0..100]}.each do |tiv|
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
                        tivoli_job    = Job.where(workstation: workstation, job_name: job).where("stream = ? OR stream_related = ?",stream, stream).first
                        unless tivoli_job.blank? 
=begin
                          job_histories = tivoli_job.job_histories.where.not(status: "ERR").order(:start_datetime).last(10)
                          dates         = job_histories.collect{|x| x.start_datetime.strftime('%m/%d')}
                          elapsed_times = job_histories.collect{|x| x.elapsed_time[3..4]} 
                          link_to @chart_icon.html_safe, "#", "data-dates" => "#{ dates }", "data-elapsed_time" => "#{ elapsed_times }", "data-job_name" => "#{line_splitted[7]}", "data-toggle" => "modal", "data-target" => "#modChart"
=end
                          link_to @chart_icon.html_safe, admin_job_path(tivoli_job), target: "_blank"
                        end
                      end
                    end
                    span link_to @log_icon.html_safe, admin_job_log_path(job: line_splitted[7], server_run: @w.url, server_port: @w.port.to_s, job_log: line_splitted[8]), target: "_blank", style: @style_color, title: line_splitted[8]
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

      column class: "datastage" do
        panel "Datastage Job live Run" do
          #$redis.get('live_dsd_data').gsub!("\t\t", "").split("\n").collect{|c| p c.split("\t")}.each do |dsd|
          jobs_txt = $redis.get('live_dsd_data').gsub!("\t\t", "").split("\n").collect{|c| p c.split("\t")}
          if jobs_txt.blank? 
            columns style: "font-size: 10px" do
              column class: "text", style: "" do
                p "nothing to show!"
              end
            end
          else
            jobs_txt.each do |dsd|
              columns style: "font-size: 10px; backgorund-color: white;" do
                #line_splitted = dsd.split(" ")
                line_splitted = dsd
                @icon = "play-circle"
                @style_color = "color: black"
                column class: "text", style: "" do
                  span (fa_icon(@icon+' 1x') +" "+ line_splitted[2]).html_safe, style: @style_color
                end
                column do
                  span line_splitted[1], style: @style_color
                end
              end
            end
          end
        end
      end
    end

# comment out graphical generator 
=begin

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

=end
 
  end # content
end

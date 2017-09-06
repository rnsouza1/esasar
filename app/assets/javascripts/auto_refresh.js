var vTimeOut;

$(function() {
	if ("/admin/live_run" === window.location.pathname) {
  		vTimeOut = setTimeout(startRefresh, 60000)
  	}
});

function startRefresh() {
    //setTimeout(startRefresh,15000);
    clearInterval(vTimeOut);
	vTimeOut= setTimeout(startRefresh, 60000);
	location.reload(); 
}

$(document).on('ready', function() {

//	$('a.load-chart').click(function(e) {
	$('#modChart').on('shown.bs.modal',function(e){
		//var ctx = $("#modChart");
	    if (typeof jobChart !== 'undefined') {
	    	jobChart.destroy();
	    }
	    var modal = $(this);
		var canvas = modal.find('.modal-body canvas');
		var link = $(e.relatedTarget);
		var labels = JSON.parse(link.attr('data-dates'));
		var source = JSON.parse(link.attr('data-elapsed_time'));
	    //modal.find('.modal-title').html("Chart");
	    var ctx = canvas[0].getContext("2d");
	    //ctx.data('elapsed_time', e.currentTarget.dataset.elapsed_time);
	    //ctx.data('dates', e.currentTarget.dataset.dates);
		var jobChart = new Chart(ctx, {
		    type: 'line',
		    data: {
		        labels: labels, //JSON.parse(e.currentTarget.dataset.dates),
		        datasets: [{
		            label: 'Elapsed Time in minutes',
		            data: source, //JSON.parse(e.currentTarget.dataset.elapsed_time),
		        }]
		    },
		    options: {
		        scales: {
		            yAxes: [{
		                ticks: {
		                    beginAtZero:true
		                }
		            }]
		        }
		    }
		});
	}).on('hidden.bs.modal',function(event){
	    // reset canvas size
	    var modal = $(this);
	    var canvas = modal.find('.modal-body canvas');
	    canvas.attr('width','568px').attr('height','300px');
	    // destroy modal
	    $(this).data('bs.modal', null);
	});	
});
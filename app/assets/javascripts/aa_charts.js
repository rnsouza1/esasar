$(document).ready(function(){
	var ctx = $("#myChart");
	if (typeof ctx !== 'undefined') {
		var myChart = new Chart(ctx, {
		    type: 'line',
		    data: {
		        labels: ctx.data('dates'),
		        datasets: [{
		            label: 'Elapsed Time in minutes',
		            data: ctx.data('elapsed_time'),
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
	}
})


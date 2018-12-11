$(document).ready(function() {
	var galaxyRoot = typeof Galaxy != 'undefined' ? Galaxy.root : '/';

	var GRTRuntimeAppView = Backbone.View.extend({
		el: '#runtime',

		appTemplate: _.template(
			'<div id="runtime-header">' +
				'<div id="runtime-name">Run Time Distribution for this Tool</div>' +
			'</div>' +
			'<svg id="runtime-svg" height="500" width="900"></svg>'
		),

		initialize: function() {
			this.render();
		},

		render: function() {
			this.$el.html(this.appTemplate({}));
			$.getScript("https://d3js.org/d3.v3.js", function(data, status){
				var svg = d3.select("#runtime-svg");
				var margin = {top: 20, right: 20, bottom: 50, left: 40},
					width = +svg.attr("width") - margin.left - margin.right,
					height = +svg.attr("height") - margin.top - margin.bottom;

				var x = d3.scale.ordinal().rangeRoundBands([0, width], 0.01),
					y = d3.scale.linear().range([height, 0]);

				var xAxis = d3.svg.axis().scale(x).orient("bottom");
				var yAxis = d3.svg.axis().scale(y).orient("left").ticks(10);

				var g = svg.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

				var tool_id = document.getElementById("webhook-view").getAttribute('tool_id').replace(/\//g,'_');

				d3.json("https://telescope.galaxyproject.org/api/tools/runtimes/1/" + tool_id + ".json", function(error, data) {
					if (error) throw error;

					x.domain(data.map(function(d) { return d[0]; }));
					y.domain([0, d3.max(data, function(d) { return d[1]; })]);

					g.append("g")
						.attr("class", "axis axis--x")
						.attr("transform", "translate(-40," + height + ")")
						.call(xAxis);

					g.append("g")
						.attr("class", "axis axis--y")
						.call(yAxis);

					g.selectAll(".bar")
						.data(data)
						.enter().append("rect")
						.attr("class", "bar")
						.attr("x", function(d) { return x(d[0]); })
						.attr("y", function(d) { return y(d[1]); })
						.attr("width", x.rangeBand())
						.attr("height", function(d) { return height - y(d[1]); });

					// text label for the x axis
					g.append("text")
						.attr("transform", "translate(" + (width/2) + " ," + (height + margin.top + 20) + ")")
						.style("text-anchor", "middle")
						.text("Runtime (s)");

					// text label for the y axis
					g.append("text")
						.attr("transform", "rotate(-90)")
						.attr("y", 0 - margin.left)
						.attr("x",0 - (height / 2))
						.attr("dy", "1em")
						.style("text-anchor", "middle")
						.text("Jobs");
				});
			});
			return this;
		},
	});

	new GRTRuntimeAppView();
});

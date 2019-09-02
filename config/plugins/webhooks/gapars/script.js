$(document).ready(function() {
	var galaxyRoot = typeof Galaxy != 'undefined' ? Galaxy.root : '/';

	var IframeAppView = Backbone.View.extend({
		el: '#iframe',

		iframeTemplate: _.template(
			'<div id="webhook-iframe-parent">' +
			'<div id="iframe-header">' +
				'<div id="iframe-name">Massively Multiplayer Online Science</div>' +
				'<div id="announcement"></div>' +
				'<div class="clearfix"></div>' +
			'</div>' +
			'<iframe id="webhook-iframe" src="https://usegalaxy.eu/gapars-experiment/" style="width: 100%; height: 800px; border: none;">' +
			'</div>'
		),

		announcementTemplate: _.template(
		    '<a href="<%= target %>"><%= announce %></a>'
		),

		initialize: function() {
			var self = this;
			this.$el.html(this.iframeTemplate());
			return this;
		}
	});

	var IframeApp = new IframeAppView;
});

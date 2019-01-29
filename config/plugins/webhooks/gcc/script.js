$(document).ready(function() {

	var galaxyRoot = typeof Galaxy != 'undefined' ? Galaxy.root : '/';

	var GccIframeAppView = Backbone.View.extend({
		el: '#gcc',

		appTemplate: _.template(
            '<div id="webhook-iframe-parent"></div>'
		),

		iframeTemplate: _.template(
			'<div id="iframe-header">' +
				'<div id="iframe-name"><%= title %></div>' +
				'<div id="vote-button"><a href="https://goo.gl/forms/lcPoMt4iZ8hwcdM12?refresh=1m&orgId=1&from=now-3h&to=now&panelId=38">Vote for your favorite training topic NOW!</a></div>' +
				'<div class="clearfix"></div>' +
			'</div>' +
			'<iframe id="webhook-iframe" src="<%= src %>" style="width: 100%; height: <%= height %>px; border: none;">'
		),

		initialize: function() {
			var self = this;
			this.$el.html(this.appTemplate());
			this.iframe = this.$('#webhook-iframe-parent');

			$.getJSON(galaxyRoot + 'api/webhooks/gcc/data', function(data) {
				self.iframe.html(self.iframeTemplate({src: data.src, height: data.height, title: data.title}));
			});
			return this;
		}

	});

	var GccIframeApp = new GccIframeAppView;
});

$(document).ready(function() {

	var galaxyRoot = typeof Galaxy != 'undefined' ? Galaxy.root : '/';

	var IframeAppView = Backbone.View.extend({
		el: '#iframe',

		appTemplate: _.template(
            '<div id="webhook-iframe-parent"></div>'
		),

		iframeTemplate: _.template(
			'<div id="iframe-header">' +
				'<div id="iframe-name"><%= title %></div>' +
				'<div id="announcement"></div>' +
				'<div class="clearfix"></div>' +
			'</div>' +
			'<iframe id="webhook-iframe" src="<%= src %>" style="width: 100%; height: <%= height %>px; border: none;">'
		),

		announcementTemplate: _.template(
		    '<a href="<%= target %>"><%= announce %></a>'
		),

		initialize: function() {
			var self = this;
			this.$el.html(this.appTemplate());
			this.iframe = this.$('#webhook-iframe-parent');

			$.getJSON(galaxyRoot + 'api/webhooks/iframe/data', function(data) {
				self.iframe.html(self.iframeTemplate({src: data.src, height: data.height, title: data.title}));
				if (data.announcement) {
			        self.announcement = self.$('#announcement');
			        self.announcement.html(self.announcementTemplate({target: data.announcement.target, announce: data.announcement.announce}));
			    }
			});
			return this;
		}

	});

	var IframeApp = new IframeAppView;
});

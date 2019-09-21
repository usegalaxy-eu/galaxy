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
<<<<<<< HEAD
				'<div id="announcement"></div>' +
				'<div class="clearfix"></div>' +
			'</div>' +
			'<iframe id="webhook-iframe" src="<%= src %>" style="width: 100%; height: <%= height %>px; border: none;">'
		),

		announcementTemplate: _.template(
		    '<a href="<%= target %>"><%= announce %></a>'
=======
			'</div>' +
			'<iframe id="webhook-iframe" src="<%= src %>" style="width:100%; height: <%= height %>px; border: none;">'
>>>>>>> 895895fd7e7d731bd96a225280b4719f3ce708f9
		),

		initialize: function() {
			var self = this;
			this.$el.html(this.appTemplate());
<<<<<<< HEAD
			this.iframe = this.$('#webhook-iframe-parent');

			$.getJSON(galaxyRoot + 'api/webhooks/iframe/data', function(data) {
				self.iframe.html(self.iframeTemplate({src: data.src, height: data.height, title: data.title}));
				if (data.announcement) {
			        self.announcement = self.$('#announcement');
			        self.announcement.html(self.announcementTemplate({target: data.announcement.target, announce: data.announcement.announce}));
			    }
=======
			this.$iframe = this.$('#webhook-iframe-parent');

			$.getJSON(galaxyRoot + 'api/webhooks/iframe/get_data', function(data) {
				self.$iframe.html(self.iframeTemplate({src: data.src, height: data.height, title: data.title}));
>>>>>>> 895895fd7e7d731bd96a225280b4719f3ce708f9
			});
			return this;
		}

	});

<<<<<<< HEAD
	var IframeApp = new IframeAppView;
=======
	new IframeAppView();
>>>>>>> 895895fd7e7d731bd96a225280b4719f3ce708f9
});

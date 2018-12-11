$(document).ready(function() {

    var citationNeededView = Backbone.View.extend({
        el: '#citation_needed',

        appTemplate: _.template(
            '<div id="cit_need-header">' +
                '<h3>We need your support ...</h3>' +
            '</div>' +
            '<div id="cit_need-body">' +
            'If Galaxy helped with the analysis of your data, please do not forget to <b>cite</b>:' +
            '<div id="cit_need-citation">'+
            'Afgan E et al. 2016 The Galaxy platform for accessible, reproducible and collaborative biomedical analyses: 2016 update.<br>'+
            'Nucleic Acids Res. 44, W3–W10<br>'+
            'doi:10.1093/nar/gkw343'+
            '</div>' +
            'And please <b>acknowledge</b> the Freiburg Galaxy server:' +
            '<div id="cit_need-citation">'+
            'The Galaxy server that was used for some calculations is in part funded by Collaborative Research Centre 992 Medical Epigenetics (DFG grant SFB 992/1 2012) and German Federal Ministry of Education and Research (BMBF grants 031 A538A/A538C RBC, 031L0101B/031L0101C de.NBI-epi, 031L0106 de.STAIR (de.NBI)).' +
            '</div>' +
            '</div>'
        ),


        initialize: function() {
            var me = this;
            this.render();
        },

        render: function() {
            this.$el.html(this.appTemplate());
            return this;
        }

    });

    var citNeedApp = new citationNeededView;

});

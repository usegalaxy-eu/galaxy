<%
    app_root = h.url_for("/static/plugins/visualizations/openlayers/static/")
%>

<!DOCTYPE html>
<html>
<head lang="en">
    <meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1"/>
    <title>Open layers</title>
    ${h.stylesheet_link(app_root + 'css/bootstrap.min.css')}
    ${h.stylesheet_link(app_root + 'css/font-awesome.min.css')}
    ${h.stylesheet_link(app_root + 'css/spectrum.css')}
    ${h.stylesheet_link(app_root + 'css/openlayers.css')}
    
    ${h.stylesheet_link(app_root + 'css/map_view.css')}
    ${h.javascript_link(app_root + "js/jquery.min.js")}
    ${h.javascript_link(app_root + "js/openlayers.js")}
    ${h.javascript_link(app_root + "js/filesaver.min.js")}
    ${h.javascript_link(app_root + "js/spectrum.js")}
    ${h.javascript_link(app_root + "js/proj4.js")}
    ${h.javascript_link(app_root + "js/jszip.js")}
    ${h.javascript_link(app_root + "js/jszip-utils.js")}
    ${h.javascript_link(app_root + "js/preprocess.js")}
    ${h.javascript_link(app_root + "js/preview.js")}

</head>
<body class="body-map-view">
    <div id="map-view" class="map"></div>
    <div class="map-options">
        <select id="geometry-type" class="form-control" title="Select geometry type">
            <option value="None">None</option>
            <option value="LineString">LineString</option>
            <option value="Circle">Circle</option>
            <option value="Polygon">Polygon</option>
        </select>
        <input type='text' id="color-text" title="Select color"/>
        <button id="export-png" type="button" class="btn btn-secondary btn-sm"><i class="fa fa-download"></i>Export</button>
    </div>
    ${h.javascript_link( app_root + "js/script.js")}
    <script>
        $(document).ready(function() {
            MapViewer.loadFile(`${h.url_for(controller='/datasets', action='index')}/${hda.id}/display`, `${hda.extension}`);
        });
    </script>
</body>
</html>


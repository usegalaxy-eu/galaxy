<%
    app_root = h.url_for("/static/plugins/visualizations/chiraviz/static/")
%>

<!DOCTYPE html>
<html>
<head lang="en">
    <meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1"/>
    <title>Galaxy SQLite (ChiRaViz) Data Viewer</title>
    ${h.stylesheet_link(app_root + 'css/bootstrap.min.css')}
    ${h.stylesheet_link(app_root + 'css/font-awesome.min.css')}
    ${h.stylesheet_link(app_root + 'css/rna.viz.css')}
</head>
<body class="body-rna-viz">
    <div class="main-container">
        <div class="samples-overlay loader"><span> loading... </span></div>
    </div>
    ${h.javascript_link(app_root +  "js/jquery-3.2.1.min.js")}
    ${h.javascript_link(app_root +  "js/plotly.min.js")}
    ${h.javascript_link(app_root +  "js/bootstrap.min.js")}
    ${h.javascript_link(app_root +  "js/underscore.min.js")}
    <script>
        $(document).ready(function (){
            var config = {
                href: document.location.origin,
                dataName: '${hda.name}',
                datasetID: '${trans.security.encode_id(hda.id)}',
                tableNames: {
                    % for table in hda.metadata.table_row_count:
                        "name": '${table}',
                    % endfor
                }
            };
            RNAInteractionViewer.loadData(config);
        });
    </script>
    ${h.javascript_link(app_root +  "js/rna-viz.js")}
    ${h.javascript_link(app_root +  "js/visualize-alignment.js")}
</body>
</html>

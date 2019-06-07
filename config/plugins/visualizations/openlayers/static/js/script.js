var MapViewer = (function(mv) {

    mv.defaultColor = '#ec1515';

    /** Set up events and methods for interactions with map view*/
    mv.setInteractions = (map, source) => {

        let $typeSelect = $('#geometry-type');
        let drawInteraction, snapInteraction;
        let addInteraction = () => {
            let geometryType = $typeSelect[0].value;
            if (geometryType !== 'None') {
                drawInteraction = new ol.interaction.Draw({
                    source: source,
                    type: geometryType,
                    freehand: true
                });
                drawInteraction.on('drawstart', event => {
                    let style = new ol.style.Style({
                        stroke: new ol.style.Stroke({
                            color: mv.defaultColor,
                            width: 2
                        }),
                        fill: new ol.style.Fill({
                            color: 'rgba(0, 0, 255, 0.1)'
                        })
                    });
                    event.feature.setStyle(style);
                });
                map.addInteraction(drawInteraction);
                snapInteraction = new ol.interaction.Snap({source: source});
                map.addInteraction(snapInteraction);
            }
        };
        addInteraction();
        // Onchange event for geometry select box
        $typeSelect.change(e => {
           map.removeInteraction(drawInteraction);
           map.removeInteraction(snapInteraction);
           addInteraction();
        });
    };
    
    /** Export the map view to PNG image*/
    mv.exportMap = map => {
        $('#export-png').on('click', e => {
           map.once('rendercomplete', event => {
                let canvas = event.context.canvas;
                let fileName = Math.random().toString(11).replace('0.', '');
                fileName += '.png';
                if (navigator.msSaveBlob) {
                    navigator.msSaveBlob(canvas.msToBlob(), fileName);
                } else {
                    canvas.toBlob(blob => {
                        saveAs(blob, fileName);
                    });
                }
            });
            map.renderSync();
        })
    };
    
    /** Set up the color picker*/
    mv.setUpColorPicker = map => {
        $("#color-text").spectrum({
            color: "#ec1515",
            showInput: true,
            className: "full-spectrum",
            showInitial: true,
            showPalette: true,
            showSelectionPalette: true,
            maxSelectionSize: 10,
            preferredFormat: "hex",
            change: color => {
                mv.defaultColor = color.toHexString();
            },
            palette: [
                ["rgb(0, 0, 0)", "rgb(67, 67, 67)", "rgb(102, 102, 102)",
                 "rgb(204, 204, 204)", "rgb(217, 217, 217)","rgb(255, 255, 255)"],
                ["rgb(152, 0, 0)", "rgb(255, 0, 0)", "rgb(255, 153, 0)", "rgb(255, 255, 0)", "rgb(0, 255, 0)",
                 "rgb(0, 255, 255)", "rgb(74, 134, 232)", "rgb(0, 0, 255)", "rgb(153, 0, 255)", "rgb(255, 0, 255)"], 
                ["rgb(230, 184, 175)", "rgb(244, 204, 204)", "rgb(252, 229, 205)", "rgb(255, 242, 204)", "rgb(217, 234, 211)", 
                 "rgb(208, 224, 227)", "rgb(201, 218, 248)", "rgb(207, 226, 243)", "rgb(217, 210, 233)", "rgb(234, 209, 220)", 
                 "rgb(221, 126, 107)", "rgb(234, 153, 153)", "rgb(249, 203, 156)", "rgb(255, 229, 153)", "rgb(182, 215, 168)", 
                 "rgb(162, 196, 201)", "rgb(164, 194, 244)", "rgb(159, 197, 232)", "rgb(180, 167, 214)", "rgb(213, 166, 189)", 
                 "rgb(204, 65, 37)", "rgb(224, 102, 102)", "rgb(246, 178, 107)", "rgb(255, 217, 102)", "rgb(147, 196, 125)", 
                 "rgb(118, 165, 175)", "rgb(109, 158, 235)", "rgb(111, 168, 220)", "rgb(142, 124, 195)", "rgb(194, 123, 160)",
                 "rgb(166, 28, 0)", "rgb(204, 0, 0)", "rgb(230, 145, 56)", "rgb(241, 194, 50)", "rgb(106, 168, 79)",
                 "rgb(69, 129, 142)", "rgb(60, 120, 216)", "rgb(61, 133, 198)", "rgb(103, 78, 167)", "rgb(166, 77, 121)",
                 "rgb(91, 15, 0)", "rgb(102, 0, 0)", "rgb(120, 63, 4)", "rgb(127, 96, 0)", "rgb(39, 78, 19)", 
                 "rgb(12, 52, 61)", "rgb(28, 69, 135)", "rgb(7, 55, 99)", "rgb(32, 18, 77)", "rgb(76, 17, 48)"]
            ]
        });
    };
    
    /** Create the map view */
    mv.setMap = vSource => {
        
        // get styles
        let selectedStyles = mv.setStyle(mv.defaultColor);
        let styleFunction = (feature) => {
            return selectedStyles[feature.getGeometry().getType()];
        };
        
        let tile = new ol.layer.Tile({source: new ol.source.OSM()});
        // add fullscreen handle
        let fullScreen = new ol.control.FullScreen();
        // add scale to the map
        let scaleLineControl = new ol.control.ScaleLine();

        // create vector with styles
        let vectorLayer = new ol.layer.Vector({
            source: vSource,
            style: styleFunction
        });
        
        // create map view
        let map = new ol.Map({
            controls: ol.control.defaults().extend([scaleLineControl, fullScreen]),
            interactions: ol.interaction.defaults().extend([new ol.interaction.DragRotateAndZoom()]),
            layers: [tile, vectorLayer],
            loadTilesWhileInteracting: true,
            target: 'map-view',
            view: new ol.View({
                center: [0, 0],
                zoom: 2
            })
        });
        
        // add grid lines
        let graticule = new ol.Graticule({
            strokeStyle: new ol.style.Stroke({
                color: 'rgba(255, 120, 0, 0.9)',
                width: 2,
                lineDash: [0.5, 4]
            }),
            showLabels: true
        });
        
        // modify the shapes
        map.addInteraction(new ol.interaction.Modify({source: vSource}));
        // add a slider for zooming in/out
        map.addControl(new ol.control.ZoomSlider());
        
        graticule.setMap(map);
        mv.setInteractions(map, vSource);
        mv.setUpColorPicker(map);
        mv.exportMap(map);
    };
    
    /** Set the style properties of shapes */
    mv.setStyle = selectedColor => {
        let styles = {
            'Polygon': new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: selectedColor,
                    width: 1
                }),
                fill: new ol.style.Fill({
                    color: 'rgba(0, 0, 255, 0.1)'
                })
            }),
            'Circle': new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: selectedColor,
                    width: 1
                }),
                fill: new ol.style.Fill({
                    color: 'rgba(0, 0, 255, 0.1)'
                })
            }),
            'Point': new ol.style.Style({
                image: new ol.style.Circle({
                    radius: 5,
                    fill: new ol.style.Fill({
                        color: 'rgba(0, 0, 255, 0.1)'
                    }),
                    stroke: new ol.style.Stroke({color: mv.defaultColor, width: 1})
                })
            }),
            'LineString': new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: selectedColor,
                    width: 1
                })
            }),
            'MultiLineString': new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: selectedColor,
                    width: 1
                })
            }),
            'MultiPoint': new ol.style.Style({
                image: new ol.style.Circle({
                    radius: 5,
                    fill: new ol.style.Fill({
                        color: 'rgba(0, 0, 255, 0.1)'
                    }),
                    stroke: new ol.style.Stroke({color: mv.defaultColor, width: 1})
                })
            }),
            'MultiPolygon': new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: selectedColor,
                    width: 1
                }),
                fill: new ol.style.Fill({
                    color: 'rgba(0, 0, 255, 0.1)'
                })
            }),
            'GeometryCollection': new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: selectedColor,
                    width: 1
                }),
                fill: new ol.style.Fill({
                    color: selectedColor
                }),
                image: new ol.style.Circle({
                    radius: 10,
                    fill: null,
                    stroke: new ol.style.Stroke({
                        color: selectedColor
                    })
                })
            })
        }
        return styles
    };
    
    /** Load the map GeoJson and Shapefiles*/
    mv.loadFile = (filePath, fileType) => {
        if (fileType === 'geojson') {
            mv.setMap(new ol.source.Vector({format: new ol.format.GeoJSON(), url: filePath}));
        }
        else if (fileType === 'shp') {
            loadshp({url: filePath, encoding: 'utf-8', EPSG: 4326}, geoJson => {
                let URL = window.URL || window.webkitURL || window.mozURL;
		let url = URL.createObjectURL(new Blob([JSON.stringify(geoJson)], {type: "application/json"}));
		mv.setMap(new ol.source.Vector({format: new ol.format.GeoJSON(), url: url}));
            });
        }
    };
    return mv;
}(MapViewer || {}));

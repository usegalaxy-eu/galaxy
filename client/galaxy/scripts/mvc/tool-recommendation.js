import Backbone from "backbone";
import Utils from "utils/utils";
import * as d3 from "libs/d3";


var ToolRecommendationView = Backbone.View.extend({
    el: "#tool-recommendation-view",

    initialize: function(options) {
        let toolId = options.toolId || "";
        let self = this;
        
        if (toolId.indexOf("/") > 0) {
            let toolIdSlash = toolId.split("/");
            toolId = toolIdSlash[toolIdSlash.length - 2];
        }
        Utils.request({
            type: "POST",
            url: `${Galaxy.root}api/workflows/get_tool_predictions`,
            data: {"tool_sequence": toolId},
            success: data => {
                if (data !== null && data.predicted_data.children.length > 0) {
                    self.render_tree(data.predicted_data);
                }
            }         
        });       
    },

    render_tree: function(predicted_data) {
        let margin = {top: 20, right: 30, bottom: 20, left: 200},
            width = 700 - margin.right - margin.left,
            height = 300 - margin.top - margin.bottom;
        let i = 0,
            duration = 750,
            root;
        let tree = d3.layout.tree()
            .size([height, width]);
        let diagonal = d3.svg.diagonal()
            .projection(d => { return [d.y, d.x]; });
        let svg = d3.select("#tool-recommendation-view").append("svg")
            .attr("width", width + margin.right + margin.left)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
            
        function update(source) {
            // Compute the new tree layout.
            let nodes = tree.nodes(root).reverse(),
                links = tree.links(nodes);
            // Normalize for fixed-depth.
            nodes.forEach(d => { d.y = d.depth * 180; });
            // Update the nodes…
            let node = svg.selectAll("g.node")
                .data(nodes, d => { return d.id || (d.id = ++i); });
            // Enter any new nodes at the parent's previous position.
            let nodeEnter = node.enter().append("g")
                .attr("class", "node")
                .attr("transform", d => { return "translate(" + source.y0 + "," + source.x0 + ")"; })
                .on("click", click);
            nodeEnter.append("circle")
                .attr("r", 1e-6)
                .style("fill", d => { return d._children ? "lightsteelblue" : "#fff"; });
            nodeEnter.append("text")
                .attr("x", d => { return d.children || d._children ? -10 : 10; })
                .attr("dy", ".35em")
                .attr("text-anchor", d => { return d.children || d._children ? "end" : "start"; })
                .text(d => { return d.name; })
                .style("fill-opacity", 1e-6);
            // Transition nodes to their new position.
            let nodeUpdate = node.transition()
                .duration(duration)
                .attr("transform", d => { return "translate(" + d.y + "," + d.x + ")"; });
            nodeUpdate.select("circle")
                .attr("r", 4.5)
                .style("fill", d => { return d._children ? "lightsteelblue" : "#fff"; });
            nodeUpdate.select("text")
                .style("fill-opacity", 1);
            // Transition exiting nodes to the parent's new position.
            let nodeExit = node.exit().transition()
                .duration(duration)
                .attr("transform", d => { return "translate(" + source.y + "," + source.x + ")"; })
                .remove();
            nodeExit.select("circle")
                .attr("r", 1e-6);
            nodeExit.select("text")
                .style("fill-opacity", 1e-6);
            // Update the links…
            let link = svg.selectAll("path.link")
                .data(links, d => { return d.target.id; });
            // Enter any new links at the parent's previous position.
            link.enter().insert("path", "g")
                .attr("class", "link")
                .attr("d", d => {
                    let o = {x: source.x0, y: source.y0};
                    return diagonal({source: o, target: o});
                });
            // Transition links to their new position.
            link.transition()
                .duration(duration)
                .attr("d", diagonal);
            // Transition exiting nodes to the parent's new position.
            link.exit().transition()
                .duration(duration)
                .attr("d", d => {
                    let o = {x: source.x, y: source.y};
                    return diagonal({source: o, target: o});
                })
                .remove();
            // Stash the old positions for transition.
            nodes.forEach(d => {
                d.x0 = d.x;
                d.y0 = d.y;
            });
        }
        // Toggle children on click.
        function click(d) {
            if (d.children) {
                d._children = d.children;
                d.children = null;
            } else {
                d.children = d._children;
                d._children = null;
            }
            update(d);
        }
        function collapse(d) {
            if (d.children) {
                d._children = d.children;
                d._children.forEach(collapse);
                d.children = null;
            }
        }
        d3.select(self.frameElement).style("height", "400px");
        root = predicted_data;
        root.x0 = height / 2;
        root.y0 = 0;
        root.children.forEach(collapse);
        update(root);
    }
});

export default {
    ToolRecommendationView: ToolRecommendationView
};

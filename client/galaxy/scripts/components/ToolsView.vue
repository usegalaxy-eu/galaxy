<template>
  <div>
    <h2 class="mb-3">
      <span id="tools-view">Tools View</span>
    </h2>
    <b-card-group columns>
      <b-card
        v-for="(info, index) in toolsExtracted"
        :key="index"
        :header="info['section']"
        :title="info['name']"
        :sub-title="info['version'] + ' / ' + info['id'] "
      >
        <p class="card-text">
          {{ info["description"] }}
        </p>
        <Citations
          simple
          source="tools"
          :id="info['id']"
        />
      </b-card>
    </b-card-group>
  </div>
</template>

<script>
import { getAppRoot } from "onload/loadConfig";
import axios from "axios";
import Citations from "components/Citations.vue";

export default {
    components: {
        Citations
    },
    data() {
        return {
            tools: [],
            loading: true
        };
    },
    computed: {
        toolsExtracted() {
            function extractSections(acc, section) {
                function extractTools(_acc, tool) {
                    return tool["name"]
                        ? [
                              ..._acc,
                              {
                                  id: tool["id"],
                                  name: tool["name"],
                                  section: section["name"],
                                  description: tool["description"],
                                  url: getAppRoot() + String(tool["link"]).substring(1),
                                  version: tool["version"]
                              }
                          ]
                        : _acc;
                }
                return acc.concat(section["elems"].reduce(extractTools, []));
            }
            return this.tools
                .reduce(extractSections, [])
                .map(a => [Math.random(), a])
                .sort((a, b) => a[0] - b[0])
                .map(a => a[1]);
        }
    },
    created() {
        axios
            .get(`${getAppRoot()}api/tools`)
            .then(response => {
                this.tools = response.data;
                this.loading = false;
            })
            .catch(error => {
                console.error(error);
            });
    }
};
</script>
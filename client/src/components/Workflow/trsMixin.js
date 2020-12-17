import { getAppRoot } from "onload/loadConfig";
import TrsServerSelection from "./TrsServerSelection";
import TrsTool from "./TrsTool";
import { redirectOnImport } from "./utils";

export default {
    components: {
        TrsServerSelection,
        TrsTool,
    },
    methods: {
        importVersion(toolId, version, isRunFormRedirect = false) {
            const version_id = version.id.includes(`:${version.name}`) ? version.name : version.id;
            this.services
                .importTrsTool(this.trsSelection.id, toolId, version.name)
                .then((response_data) => {
                    redirectOnImport(getAppRoot(), response_data, isRunFormRedirect);
                })
                .catch((errorMessage) => {
                    this.errorMessage = errorMessage || "Import failed for an unknown reason.";
                });
        },
    },
};

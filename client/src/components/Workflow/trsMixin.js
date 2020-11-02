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
        importVersion(toolId, version_id, isRunFormRedirect = false) {
            this.services
                .importTrsTool(this.trsSelection.id, toolId, version_id)
                .then((response_data) => {
                    redirectOnImport(getAppRoot(), response_data, isRunFormRedirect);
                })
                .catch((errorMessage) => {
                    this.errorMessage = errorMessage || "Import failed for an unknown reason.";
                });
        },
    },
};

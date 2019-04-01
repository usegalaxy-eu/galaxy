<%namespace name="ie" file="ie.mako"/>

<%
import os
import shutil
import time

# Sets ID and sets up a lot of other variables
ie_request.load_deploy_config()
ie_request.attr.docker_port = 80
PASSWORD = "rstudio"
USERNAME = "rstudio"
# Then override it again
ie_request.notebook_pw = "rstudio"


# Add all environment variables collected from Galaxy's IE infrastructure
ie_request.launch(
    image=trans.request.params.get('image_tag', None),
    env_override={
        'notebook_username': USERNAME,
        'notebook_password': PASSWORD,
    }
)

## General IE specific
# Access URLs for the notebook from within galaxy.
notebook_access_url = ie_request.url_template('${PROXY_URL}/rstudio/')
notebook_login_url = ie_request.url_template('${PROXY_URL}/rstudio/auth-do-sign-in')
notebook_pubkey_url = ie_request.url_template('${PROXY_URL}/rstudio/auth-public-key')

%>
<html>
<head>
${ ie.load_default_js() }
</head>
<body style="margin: 0px">

<script type="text/javascript">
${ ie.default_javascript_variables() }
var notebook_login_url = '${ notebook_login_url }';
var notebook_access_url = '${ notebook_access_url }';
var notebook_pubkey_url = '${ notebook_pubkey_url }';

require.config({
    baseUrl: app_root,
    paths: {
        "plugin" : app_root + "js",
        "crypto" : app_root + "js/crypto/",
        "galaxy.interactive_environments": "${h.url_for('/static/scripts/galaxy.interactive_environments')}",
    },
    urlArgs: "v=${app.server_starttime}",
});
window.onbeforeunload = function() {
    return 'You are leaving your Interactive Environment.';
};

requirejs([
    'galaxy.interactive_environments',
    'crypto/prng4',
    'crypto/rng',
    'crypto/rsa',
    'crypto/jsbn',
    'crypto/base64',
    'plugin/rstudio'
], function(IES){
    window.IES = IES;
    IES.load_when_ready(ie_readiness_url, function(){
        load_notebook(notebook_login_url, notebook_access_url, notebook_pubkey_url);
    });
});
</script>
<div id="main" width="100%" height="100%">
</div>
</body>
</html>

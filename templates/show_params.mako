<%inherit file="/base.mako"/>
<%namespace file="/message.mako" import="render_msg" />
<% from galaxy.util import nice_size, unicodify %>

<style>
    .inherit {
        border: 1px solid #bbb;
        padding: 15px;
        text-align: center;
        background-color: #eee;
    }

    table.info_data_table {
        table-layout: fixed;
        word-break: break-word;
    }
    table.info_data_table td:nth-child(1) {
        width: 25%;
    }

</style>

<%def name="inputs_recursive( input_params, param_values, depth=1, upgrade_messages=None )">
    <%
        from galaxy.util import listify
        if upgrade_messages is None:
            upgrade_messages = {}
    %>
    %for input_index, input in enumerate( input_params.values() ):
        %if input.name in param_values:
            %if input.type == "repeat":
                %for i in range( len(param_values[input.name]) ):
                    ${ inputs_recursive(input.inputs, param_values[input.name][i], depth=depth+1) }
                %endfor
            %elif input.type == "section":
                <tr>
                    ##<!-- Get the value of the current Section parameter -->
                    ${inputs_recursive_indent( text=input.name, depth=depth )}
                    <td></td>
                </tr>
                ${ inputs_recursive( input.inputs, param_values[input.name], depth=depth+1, upgrade_messages=upgrade_messages.get( input.name ) ) }
            %elif input.type == "conditional":
                <%
                try:
                    current_case = param_values[input.name]['__current_case__']
                    is_valid = True
                except:
                    current_case = None
                    is_valid = False
                %>
                %if is_valid:
                    <tr>
                        ${ inputs_recursive_indent( text=input.test_param.label, depth=depth )}
                        ##<!-- Get the value of the current Conditional parameter -->
                        <td>${input.cases[current_case].value | h}</td>
                        <td></td>
                    </tr>
                    ${ inputs_recursive( input.cases[current_case].inputs, param_values[input.name], depth=depth+1, upgrade_messages=upgrade_messages.get( input.name ) ) }
                %else:
                    <tr>
                        ${ inputs_recursive_indent( text=input.name, depth=depth )}
                        <td><em>The previously used value is no longer valid</em></td>
                        <td></td>
                    </tr>
                %endif
            %elif input.type == "upload_dataset":
                    <tr>
                        ${inputs_recursive_indent( text=input.group_title( param_values ), depth=depth )}
                        <td>${ len( param_values[input.name] ) } uploaded datasets</td>
                        <td></td>
                    </tr>
            ## files used for inputs
            %elif input.type == "data":
                    <tr>
                        ${inputs_recursive_indent( text=input.label, depth=depth )}
                        <td>
                        %for i, element in enumerate(listify(param_values[input.name])):
                            %if i > 0:
                            ,
                            %endif
                            %if element.history_content_type == "dataset":
                                <%
                                    hda = element
                                    encoded_id = trans.security.encode_id( hda.id )
                                    show_params_url = h.url_for( controller='dataset', action='show_params', dataset_id=encoded_id )
                                %>
                                <a class="input-dataset-show-params" data-hda-id="${encoded_id}"
                                       href="${show_params_url}">${hda.hid}: ${hda.name | h}</a>

                            %else:
                                ${element.hid}: ${element.name | h}
                            %endif
                        %endfor
                        </td>
                        <td></td>
                    </tr>
             %elif input.visible:
                <%
                if  hasattr( input, "label" ) and input.label:
                    label = input.label
                else:
                    #value for label not required, fallback to input name (same as tool panel)
                    label = input.name
                %>
                <tr>
                    ${inputs_recursive_indent( text=label, depth=depth )}
                    <td>${input.value_to_display_text( param_values[input.name] ) | h}</td>
                    <td>${ upgrade_messages.get( input.name, '' ) | h }</td>
                </tr>
            %endif
        %else:
            ## Parameter does not have a stored value.
            <tr>
                <%
                    # Get parameter label.
                    if input.type == "conditional":
                        label = input.test_param.label
                    elif input.type == "repeat":
                        label = input.label()
                    else:
                        label = input.label or input.name
                %>
                ${inputs_recursive_indent( text=label, depth=depth )}
                <td><em>not used (parameter was added after this job was run)</em></td>
                <td></td>
            </tr>
        %endif

    %endfor
</%def>

 ## function to add a indentation depending on the depth in a <tr>
<%def name="inputs_recursive_indent( text, depth )">
    <td style="padding-left: ${ ( depth - 1 ) * 10 }px">
        ${text | h}
    </td>
</%def>

<h2>
% if tool:
    ${tool.name | h}
% else:
    Unknown Tool
% endif
</h2>

<h3>Dataset Information</h3>
<table class="tabletip" id="dataset-details">
    <tbody>
        <%
        encoded_hda_id = trans.security.encode_id( hda.id )
        encoded_history_id = trans.security.encode_id( hda.history_id )
        %>
        <tr><td>Number:</td><td>${hda.hid | h}</td></tr>
        <tr><td>Name:</td><td>${hda.name | h}</td></tr>
        <tr><td>Created:</td><td>${unicodify(hda.create_time.strftime(trans.app.config.pretty_datetime_format))}</td></tr>
        ##      <tr><td>Copied from another history?</td><td>${hda.source_library_dataset}</td></tr>
        <tr><td>Filesize:</td><td>${nice_size(hda.dataset.file_size)}</td></tr>
        <tr><td>Dbkey:</td><td>${hda.dbkey | h}</td></tr>
        <tr><td>Format:</td><td>${hda.ext | h}</td></tr>
    </tbody>
</table>

<h3>Job Information</h3>
<table class="tabletip">
    <tbody>
        %if job:
            <tr><td>Galaxy Tool ID:</td><td>${ job.tool_id | h }</td></tr>
            <tr><td>Galaxy Tool Version:</td><td>${ job.tool_version | h }</td></tr>
        %endif
        <tr><td>Tool Version:</td><td>${hda.tool_version | h}</td></tr>
        <tr><td>Tool Standard Output:</td><td><a href="${h.url_for( controller='dataset', action='stdout', dataset_id=encoded_hda_id )}">stdout</a></td></tr>
        <tr><td>Tool Standard Error:</td><td><a href="${h.url_for( controller='dataset', action='stderr', dataset_id=encoded_hda_id )}">stderr</a></td></tr>
        %if job:
            <tr><td>Tool Exit Code:</td><td>${ job.exit_code | h }</td></tr>
            %if job.job_messages:
            <tr><td>Job Messages</td><td><ul style="padding-left: 15px; margin-bottom: 0px">
            %for job_message in job.job_messages:
            <li>${ job_message['desc'] |h }</li>
            %endfor
            <ul></td></tr>
            %endif
        %endif
        <tr><td>History Content API ID:</td>
        <td>${encoded_hda_id}
            %if trans.user_is_admin:
                (${hda.id})
            %endif
        </td></tr>
        %if job:
            <tr><td>Job API ID:</td>
            <td>${trans.security.encode_id( job.id )}
                %if trans.user_is_admin:
                    (${job.id})
                %endif
            </td></tr>
        %endif
        <tr><td>History API ID:</td>
        <td>${encoded_history_id}
            %if trans.user_is_admin:
                (${hda.history_id})
            %endif
        </td></tr>
        %if hda.dataset.uuid:
        <tr><td>UUID:</td><td>${hda.dataset.uuid}</td></tr>
        %endif
        %if trans.user_is_admin or trans.app.config.expose_dataset_path:
            %if not hda.purged:
                <tr><td>Full Path:</td><td>${hda.file_name | h}</td></tr>
            %endif
        %endif
    </tbody>
</table>

<h3>Tool Parameters</h3>
<table class="tabletip" id="tool-parameters">
    <thead>
        <tr>
            <th>Input Parameter</th>
            <th>Value</th>
            <th>Note for rerun</th>
        </tr>
    </thead>
    <tbody>
        % if params_objects and tool:
            ${ inputs_recursive( tool.inputs, params_objects, depth=1, upgrade_messages=upgrade_messages ) }
        %elif params_objects is None:
            <tr><td colspan="3">Unable to load parameters.</td></tr>
        % else:
            <tr><td colspan="3">No parameters.</td></tr>
        % endif
    </tbody>
</table>
%if has_parameter_errors:
    <br />
    ${ render_msg( 'One or more of your original parameters may no longer be valid or displayed properly.', status='warning' ) }
%endif


<h3>Inheritance Chain</h3>
<div class="inherit" style="background-color: #fff; font-weight:bold;">${hda.name | h}</div>

% for dep in inherit_chain:
    <div style="font-size: 36px; text-align: center; position: relative; top: 3px">&uarr;</div>
    <div class="inherit">
        '${dep[0].name | h}' in ${dep[1]}<br/>
    </div>
% endfor



%if job and job.command_line and (trans.user_is_admin or trans.app.config.expose_dataset_path):
<h3>Command Line</h3>
<pre class="code">
${ job.command_line | h }</pre>
%endif

%if job and (trans.user_is_admin or trans.app.config.expose_potentially_sensitive_job_metrics):
<h3>Job Metrics</h3>
<% job_metrics = trans.app.job_metrics %>
<% plugins = set([metric.plugin for metric in job.metrics]) %>
    %for plugin in sorted(plugins):
    %if trans.user_is_admin or plugin != 'env':
    <h4>${ plugin | h }</h4>
    <table class="tabletip info_data_table">
        <tbody>
        <%
            plugin_metrics = filter(lambda x: x.plugin == plugin, job.metrics)
            plugin_metric_displays = [job_metrics.format( metric.plugin, metric.metric_name, metric.metric_value ) for metric in plugin_metrics]
            plugin_metric_displays = sorted(plugin_metric_displays, key=lambda pair: pair[0])  # Sort on displayed title
        %>
            %for metric_title, metric_value in plugin_metric_displays:
                <tr><td>${ metric_title | h }</td><td>${ metric_value | h }</td></tr>
            %endfor
        </tbody>
    </table>
    %endif
    %endfor
%endif

<%
ec2 = {
    'CVRPW534R69RUEMP': {'name': 't3.nano', 'mem': 0.5, 'price': 0.006, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'BXS2CDUKEC83Q4SH': {'name': 'm5.xlarge', 'mem': 16.0, 'price': 0.23, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon Platinum 8175'},
    '5ZJ896MTVHB5JV5Y': {'name': 't2.medium', 'mem': 4.0, 'price': 0.0536, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon Family'},
    'GHQYBQHT7SSW3G2C': {'name': 't2.large', 'mem': 8.0, 'price': 0.1072, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon Family'},
    '8KTQAHWA58GUHDGC': {'name': 'm3.large', 'mem': 7.5, 'price': 0.158, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)'},
    'FVQQQM6YZMWR2CH8': {'name': 'm5d.12xlarge', 'mem': 192.0, 'price': 3.264, 'priceunit': 'Hrs', 'vcpus': 48, 'cpu': 'Intel Xeon Platinum 8175'},
    'XWVCP8TVZ3EZXHJT': {'name': 'm4.10xlarge', 'mem': 160.0, 'price': 2.4, 'priceunit': 'Hrs', 'vcpus': 40, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    '4K2RDTDA5QDSVF79': {'name': 'm5d.2xlarge', 'mem': 32.0, 'price': 0.544, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon Platinum 8175'},
    'WVY4KGHQEHERBSCH': {'name': 'm5d.4xlarge', 'mem': 64.0, 'price': 1.088, 'priceunit': 'Hrs', 'vcpus': 16, 'cpu': 'Intel Xeon Platinum 8175'},
    'EF7GKFKJ3Y5DM7E9': {'name': 'm4.xlarge', 'mem': 16.0, 'price': 0.24, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    'EJKFPM8NFNPPN8K3': {'name': 't3.xlarge', 'mem': 16.0, 'price': 0.192, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'VKC9JFWDJCMTC9PM': {'name': 'm5d.metal', 'mem': 384.0, 'price': 6.528, 'priceunit': 'Hrs', 'vcpus': 96, 'cpu': 'Intel Xeon Platinum 8175'},
    'KZ25CYAW7ZZ6SN5U': {'name': 't3.xlarge', 'mem': 16.0, 'price': 0.192, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    '6GR6HHW9M8KXFW8G': {'name': 't3.large', 'mem': 8.0, 'price': 0.096, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'MWZ782FC8DW7J99A': {'name': 't2.small', 'mem': 2.0, 'price': 0.0268, 'priceunit': 'Hrs', 'vcpus': 1, 'cpu': 'Intel Xeon Family'},
    'J49TZ5ZB5Y6C86JU': {'name': 't3.nano', 'mem': 0.5, 'price': 0.006, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'UZVS6KCHDUP826JV': {'name': 'm5d.12xlarge', 'mem': 192.0, 'price': 3.264, 'priceunit': 'Hrs', 'vcpus': 48, 'cpu': 'Intel Xeon Platinum 8175'},
    'MU5U93W873MZ8Z5D': {'name': 'm5.metal', 'mem': 384.0, 'price': 5.52, 'priceunit': 'Hrs', 'vcpus': 96, 'cpu': 'Intel Xeon Platinum 8175'},
    'DWFM7CT7HR9PKX7G': {'name': 'm5d.2xlarge', 'mem': 32.0, 'price': 0.544, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon Platinum 8175'},
    'H6ECMC3MHDHUV96Z': {'name': 't3.medium', 'mem': 4.0, 'price': 0.048, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'Q6FFSFPJYR84UFKC': {'name': 't2.xlarge', 'mem': 16.0, 'price': 0.2144, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon Family'},
    'WDV8EGFDZABESVSJ': {'name': 't2.micro', 'mem': 1.0, 'price': 0.0134, 'priceunit': 'Hrs', 'vcpus': 1, 'cpu': 'Intel Xeon Family'},
    '5ZZCF2WTD3M2NVHT': {'name': 'm3.xlarge', 'mem': 15.0, 'price': 0.315, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)'},
    '8SQHN34JP8S4C4GV': {'name': 't2.xlarge', 'mem': 16.0, 'price': 0.2144, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon Family'},
    'ZWPFR7HFRCGJ2QTR': {'name': 'm4.10xlarge', 'mem': 160.0, 'price': 2.4, 'priceunit': 'Hrs', 'vcpus': 40, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    '79M3634SCM5Q9T3J': {'name': 'm5.2xlarge', 'mem': 32.0, 'price': 0.46, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon Platinum 8175'},
    '7SN7STWTVJW3W2G9': {'name': 'm5d.xlarge', 'mem': 16.0, 'price': 0.272, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon Platinum 8175'},
    'N5D4RSFRNZ3SRTJ3': {'name': 'm5.2xlarge', 'mem': 32.0, 'price': 0.46, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon Platinum 8175'},
    '8KSV5UWZA8Q5NDMM': {'name': 'm5.large', 'mem': 8.0, 'price': 0.115, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon Platinum 8175'},
    'CDQ3VSAVRNG39R6V': {'name': 'm4.2xlarge', 'mem': 32.0, 'price': 0.48, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    'ASEABRAPY52SVJQW': {'name': 'm5.xlarge', 'mem': 16.0, 'price': 0.23, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon Platinum 8175'},
    'CU49Z77S6UH36JXW': {'name': 't2.small', 'mem': 2.0, 'price': 0.0268, 'priceunit': 'Hrs', 'vcpus': 1, 'cpu': 'Intel Xeon Family'},
    'BQGVWHYQ8YK6UNK7': {'name': 't3.2xlarge', 'mem': 32.0, 'price': 0.384, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'QJ82YTRR8GFNUS8T': {'name': 'm4.16xlarge', 'mem': 256.0, 'price': 3.84, 'priceunit': 'Hrs', 'vcpus': 64, 'cpu': 'Intel Xeon E5-2686 v4 (Broadwell)'},
    'JGXEWM5NJCZJPHGG': {'name': 'm4.4xlarge', 'mem': 64.0, 'price': 0.96, 'priceunit': 'Hrs', 'vcpus': 16, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    'GAZSSNJQ6FMMHE3Z': {'name': 't2.nano', 'mem': 0.5, 'price': 0.0067, 'priceunit': 'Hrs', 'vcpus': 1, 'cpu': 'Intel Xeon Family'},
    'VDE8R7MCSGDRYAK3': {'name': 'm5d.metal', 'mem': 384.0, 'price': 6.528, 'priceunit': 'Hrs', 'vcpus': 96, 'cpu': 'Intel Xeon Platinum 8175'},
    '7EFZWDA5CSAB85BF': {'name': 't2.2xlarge', 'mem': 32.0, 'price': 0.4288, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon Family'},
    '9UR7CWCC3D8XJM5D': {'name': 'm5.metal', 'mem': 384.0, 'price': 5.52, 'priceunit': 'Hrs', 'vcpus': 96, 'cpu': 'Intel Xeon Platinum 8175'},
    'PXVP8BEWB9MCWMNR': {'name': 't3.micro', 'mem': 1.0, 'price': 0.012, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'R2292NDJY8MEG6E9': {'name': 'm4.xlarge', 'mem': 16.0, 'price': 0.24, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    'WDVKBS7C22UHKEXB': {'name': 'm5.4xlarge', 'mem': 64.0, 'price': 0.92, 'priceunit': 'Hrs', 'vcpus': 16, 'cpu': 'Intel Xeon Platinum 8175'},
    '85ZP32Z5B2G2SYVH': {'name': 'm5d.24xlarge', 'mem': 384.0, 'price': 6.528, 'priceunit': 'Hrs', 'vcpus': 96, 'cpu': 'Intel Xeon Platinum 8175'},
    '5P7657GQ9EZ2Z4ZY': {'name': 't2.medium', 'mem': 4.0, 'price': 0.0536, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon Family'},
    'CNP4PV4Y2J8YZVAR': {'name': 'm3.2xlarge', 'mem': 30.0, 'price': 0.632, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)'},
    'XGAATXHUHNWXTMMR': {'name': 't3.small', 'mem': 2.0, 'price': 0.024, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'ADZF37JDQVT3WGPY': {'name': 'm5d.4xlarge', 'mem': 64.0, 'price': 1.088, 'priceunit': 'Hrs', 'vcpus': 16, 'cpu': 'Intel Xeon Platinum 8175'},
    'T9GCN3NZ9U6N5BGN': {'name': 't2.micro', 'mem': 1.0, 'price': 0.0134, 'priceunit': 'Hrs', 'vcpus': 1, 'cpu': 'Intel Xeon Family'},
    'MB2NWM9D8ZZSBHR4': {'name': 'm4.16xlarge', 'mem': 256.0, 'price': 3.84, 'priceunit': 'Hrs', 'vcpus': 64, 'cpu': 'Intel Xeon E5-2686 v4 (Broadwell)'},
    '7W6DNQ55YG9FCPXZ': {'name': 't2.large', 'mem': 8.0, 'price': 0.1072, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon Family'},
    'A65VEHYMUBAYJ5QH': {'name': 'm5.12xlarge', 'mem': 192.0, 'price': 2.76, 'priceunit': 'Hrs', 'vcpus': 48, 'cpu': 'Intel Xeon Platinum 8175'},
    'GAE4UTCSMAJWBBFJ': {'name': 'm3.2xlarge', 'mem': 30.0, 'price': 0.632, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)'},
    'A4PSTURH2MNXCCEY': {'name': 'm5.24xlarge', 'mem': 384.0, 'price': 5.52, 'priceunit': 'Hrs', 'vcpus': 96, 'cpu': 'Intel Xeon Platinum 8175'},
    'FJGAN929UK7ZM2ZP': {'name': 'm5d.large', 'mem': 8.0, 'price': 0.136, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon Platinum 8175'},
    '9F7RB34BNUJTPE58': {'name': 'm5d.large', 'mem': 8.0, 'price': 0.136, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon Platinum 8175'},
    'Z2K4FMUDPSU2Y95K': {'name': 'm5d.24xlarge', 'mem': 384.0, 'price': 6.528, 'priceunit': 'Hrs', 'vcpus': 96, 'cpu': 'Intel Xeon Platinum 8175'},
    'BMXENRM9BM54QBEV': {'name': 'm5.24xlarge', 'mem': 384.0, 'price': 5.52, 'priceunit': 'Hrs', 'vcpus': 96, 'cpu': 'Intel Xeon Platinum 8175'},
    '7X63DAK78VTPCW8F': {'name': 't3.2xlarge', 'mem': 32.0, 'price': 0.384, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'GDZZPNEEZXAN7X9J': {'name': 'm3.medium', 'mem': 3.75, 'price': 0.079, 'priceunit': 'Hrs', 'vcpus': 1, 'cpu': 'Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)'},
    '5FF8EWYB29V3BMFR': {'name': 'm4.2xlarge', 'mem': 32.0, 'price': 0.48, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    'JSXG89ERGHPGMPFM': {'name': 'm5.large', 'mem': 8.0, 'price': 0.115, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon Platinum 8175'},
    'QR7F3KDAWU8AH7GS': {'name': 'm5.4xlarge', 'mem': 64.0, 'price': 0.92, 'priceunit': 'Hrs', 'vcpus': 16, 'cpu': 'Intel Xeon Platinum 8175'},
    'S9TWRX7CSGVGFTUF': {'name': 'm3.large', 'mem': 7.5, 'price': 0.158, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)'},
    'NM35WHNW4RD6ZH4A': {'name': 't3.small', 'mem': 2.0, 'price': 0.024, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'V9KJ6N2U7KUVD6B4': {'name': 'm3.medium', 'mem': 3.75, 'price': 0.079, 'priceunit': 'Hrs', 'vcpus': 1, 'cpu': 'Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)'},
    'QDVJP86F8XHGBSMH': {'name': 'm4.4xlarge', 'mem': 64.0, 'price': 0.96, 'priceunit': 'Hrs', 'vcpus': 16, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    '9PBREHF5JRKB6RBE': {'name': 't3.micro', 'mem': 1.0, 'price': 0.012, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'RKVEJUJU9XMQKRKT': {'name': 'm5d.xlarge', 'mem': 16.0, 'price': 0.272, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon Platinum 8175'},
    'RP7JF6K2NBW9Y4SJ': {'name': 't3.medium', 'mem': 4.0, 'price': 0.048, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'QJXTGC5R5C4GXQJZ': {'name': 't2.2xlarge', 'mem': 32.0, 'price': 0.4288, 'priceunit': 'Hrs', 'vcpus': 8, 'cpu': 'Intel Xeon Family'},
    'XH9A78C54UHFZGRU': {'name': 'm4.large', 'mem': 8.0, 'price': 0.12, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    '6PSHDB8D545JMBBD': {'name': 't2.nano', 'mem': 0.5, 'price': 0.0067, 'priceunit': 'Hrs', 'vcpus': 1, 'cpu': 'Intel Xeon Family'},
    'ABFDCPB959KUGRH8': {'name': 'm4.large', 'mem': 8.0, 'price': 0.12, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Xeon E5-2676 v3 (Haswell)'},
    '94CQG9X2X6WQEE35': {'name': 'm5.12xlarge', 'mem': 192.0, 'price': 2.76, 'priceunit': 'Hrs', 'vcpus': 48, 'cpu': 'Intel Xeon Platinum 8175'},
    '5Y4HW2NEZ28KD55H': {'name': 't3.large', 'mem': 8.0, 'price': 0.096, 'priceunit': 'Hrs', 'vcpus': 2, 'cpu': 'Intel Skylake E5 2686 v5 (2.5 GHz)'},
    'FD8FGSQDGNM69YJF': {'name': 'm3.xlarge', 'mem': 15.0, 'price': 0.315, 'priceunit': 'Hrs', 'vcpus': 4, 'cpu': 'Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)'}
}
%>
<%
try:
    pm = filter(lambda x: x.plugin == 'core', job.metrics)
    seconds = int([m.metric_value for m in pm if m.metric_name == 'runtime_seconds'][0])
    vcpus   = int([m.metric_value for m in pm if m.metric_name == 'galaxy_slots'][0])
    mem = 4

    for (k, v) in job.destination_params.items():
      if k == 'request_memory':
        mem = float(v.replace('G', ''))

    for sku, data in sorted(ec2.items(), key=lambda x: (x[1]['mem'], x[1]['vcpus'])):
        if data['mem'] >= mem and data['vcpus'] >= vcpus:

            if data['priceunit'] != 'Hrs':
                raise Exception()

            price = seconds * data['price'] / 3600
            pricef = "%0.02f" % price
            instance = data
            break
except:
    mem = -1
    pass
%>

%if mem >= 0:
<h3>AWS Estimate</h3>
<b>${pricef} USD</b><br/>

This job requested ${vcpus} cores and ${mem} Gb. Given this, the smallest EC2
machine we could find is ${instance['name']} (${instance['mem']} GB /
${instance['vcpus']} vCPUs / ${instance['cpu']}). That instance is priced at
${instance['price']} USD/hour.
%endif


%if trans.user_is_admin:
<h3>Destination Parameters</h3>
    <table class="tabletip">
        <tbody>
            <tr><th scope="row">Runner</th><td>${ job.job_runner_name }</td></tr>
            <tr><th scope="row">Runner Job ID</th><td>${ job.job_runner_external_id }</td></tr>
            <tr><th scope="row">Handler</th><td>${ job.handler }</td></tr>
            %if job.destination_params:
            %for (k, v) in job.destination_params.items():
                <tr><th scope="row">${ k | h }</th>
                    <td>
                        %if str(k) in ('nativeSpecification', 'rank', 'requirements'):
                        <pre style="white-space: pre-wrap; word-wrap: break-word;">${ v | h }</pre>
                        %else:
                        ${ v | h }
                        %endif
                    </td>
                </tr>
            %endfor
            %endif
        </tbody>
    </table>
%endif

%if job and job.dependencies:
<h3>Job Dependencies</h3>
    <table class="tabletip">
        <thead>
        <tr>
            <th>Dependency</th>
            <th>Dependency Type</th>
            <th>Version</th>
            %if trans.user_is_admin:
            <th>Path</th>
            %endif
        </tr>
        </thead>
        <tbody>

            %for dependency in job.dependencies:
                <tr><td>${ dependency['name'] | h }</td>
                    <td>${ dependency['dependency_type'] | h }</td>
                    <td>${ dependency['version'] | h }</td>
                    %if trans.user_is_admin:
                        %if 'environment_path' in dependency:
                        <td>${ dependency['environment_path'] | h }</td>
                        %elif 'path' in dependency:
                        <td>${ dependency['path'] | h }</td>
                        %else:
                        <td></td>
                        %endif
                    %endif
                </tr>
            %endfor

        </tbody>
    </table>
%endif

%if hda.peek:
    <h3>Dataset peek</h3>
    <pre class="dataset-peek">${hda.peek}
    </pre>
%endif


<script type="text/javascript">
$(function(){
    $( '.input-dataset-show-params' ).on( 'click', function( ev ){
        ## some acrobatics to get the Galaxy object that has a history from the contained frame
        if( window.parent.Galaxy && window.parent.Galaxy.currHistoryPanel ){
            window.parent.Galaxy.currHistoryPanel.scrollToId( 'dataset-' + $( this ).data( 'hda-id' ) );
        }
    })
});
</script>

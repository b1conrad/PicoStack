ruleset org.picostack.logging {
  meta {
    name "logs"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares log
  }
  global {
    event_domain = "org_picostack_logging"
    styles = <<<style type="text/css">
ul#logsul {
  margin: 0px;
  padding: 0px;
  list-style-type: none;
  width: auto;
}
ul#logsul li {
  white-space: pre;
  font-family: monospace;
  display: block;
}
</style>
>>
    log = function(_headers){
      uiECI = wrangler:channels(["engine","ui"]).head().get("id")
      url = <<#{meta:host}/sky/cloud/#{uiECI}/io.picolabs.pico-engine-ui/logs>>
      html:header("manage logs",styles,null,null,_headers)
      + <<
<h1>Manage logs</h1>
<ul id="logsul"></ul>
>>
      + <<<script type="text/javascript">
  var the_ul = document.getElementById('logsul');
  var url = "#{url}";
  var xhr = new XMLHttpRequest();
  xhr.open('GET',url);
  xhr.responseType = 'json';
  xhr.onload = function(){
    var logs_array = this.response;
    console.log('response',this.response);
    for(var i=0; i<logs_array.length; ++i){
      var episode = logs_array[i];
      var the_li = document.createElement('li');
      the_li.appendChild(document.createTextNode(episode.time+' - '+episode.header));
      the_ul.appendChild(the_li);
    }
  }
  xhr.send();
</script>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["logs"],
        {"allow":[{"domain":"org_picostack_logging","name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise org_picostack_logging event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when org_picostack_logging factory_reset
    foreach wrangler:channels(["logs"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
}

ruleset org.picostack.logging {
  meta {
    name "logs"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares log
  }
  global {
    event_domain = "org_picostack_logging"
    log = function(_headers){
      uiECI = wrangler:channels(["engine","ui"]).head().get("id")
      url = <<#{meta:host}/sky/cloud/#{uiECI}/io.picolabs.pico-engine-ui/logs>>
      script = <<<script type="text/javascript">
  var xhr = new XMLHttpRequest();
  xhr.onload = function(){
    var data = xhr.response;
    console.log(JSON.stringify(data));
  }
  xhr.open("GET",#{url});
  xhr.send();
</script>
>>
      html:header("manage logs","",null,null,_headers)
      + <<
<h1>Manage logs</h1>
<pre id="logspre"></pre>
>>
      + script
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

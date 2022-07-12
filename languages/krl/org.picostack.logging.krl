ruleset org.picostack.logging {
  meta {
    name "logs"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares log, settings
  }
  global {
    event_domain = "org_picostack_logging"
/*
* Page: log.html
*/
    styles = <<<style type="text/css">
ul#logging-list {
  padding: 0px;
}
ul#logging-list li {
  white-space: nowrap;
  font-family: monospace;
}
.logging-detail {
  margin: 0 0 0 18px;
  display: none;
}
ul#logging-list label {
  cursor: pointer;
}
ul#logging-list li input[type="checkbox"]:checked ~ .logging-detail {
  display: block;
}
</style>
>>
    log_li = function(episode,index){
      key = episode{"time"} + " - " + episode{"header"}
      <<<li>
  <input type="checkbox" id="episode-#{index}">
  <label for="episode-#{index}">#{key}</label>
  <pre class="logging-detail">#{episode{"entries"}.join(chr(10))}
</pre>
</li>
>>
    }
    log = function(_headers){
//      since = ent:episodes.head().get("time") || ""
      episodes = logs()
//        .filter(function(e){e{"time"} > since})
//        .append(ent:episodes)
      html:header("manage logs",styles,null,null,_headers)
      + <<
<h1
  style="float:right;cursor:pointer"
  title="Settings"
  onclick="location='settings.html'">⚙</h1>
<h1>Manage logs</h1>
<ul id="logging-list">
#{episodes.map(log_li).join("")}</ul>
>>
      + html:footer()
    }
/*
* Page: settings.html
*/
    settings = function(_headers){
      oqs = function(re){
        re.as("String")
      }
      html:header("manage logs",styles,null,null,_headers)
      + <<
<h1>Manage logging settings</h1>
<pre><code>#{
  ent:omitQuery
    .map(oqs)
    .values()
    .join(chr(10))
}</code></pre>
>>
      + html:footer()
    }
/*
* Internal: logs function
*/
    logs = function(){
      omit_common = function(g){
        hdr = g.get("header")
        ent:omitQuery.none(function(regExp){hdr.match(regExp)})
      }
      logOther = function(entry){
        entry.delete("time")
          .delete("level")
          .delete("msg")
          .delete("txnId")
          .encode()
      }
      logQuery = function(query){
        args = query.get("args").delete("_headers") || {}
        <<QUERY #{query.get("eci")} #{query.get("rid")}/#{query.get("name")} #{args.encode()}>>
      }
      logEvent = function(event){
        attrs = event.get(["data","attrs"]).delete("_headers") || {}
        <<EVENT #{event.get("eci")} #{event.get("domain")}:#{event.get("name")} #{attrs.encode()}>>
      }
      logFirst = function(entry){
        txn = entry.get("txn")
        kind = txn.get("kind")
        kind == "query" => logQuery(txn.get("query")) |
        kind == "event" => logEvent(txn.get("event")) |
        logOther(entry)
      }
      logDetails = function(entry){
        msg = entry.get("msg")
        msg == "txnQueued" => logFirst(entry) |
        msg == "event added to schedule" => entry.get("event").encode() |
        msg == "rule selected" => <<#{entry.get("rid")} : #{entry.get("rule_name")}>> |
        entry.get("level") == "klog" => entry.get("val").encode() || "null" |
        msg.match(re#fired$#) => "" |
        logOther(entry)
      }
      episode_line = function(x,i){
        level = x{"level"}.uc();
        x{"time"}.split("T")[1] +
          " [" +
          level +
          "] "+
          x{"msg"} +
          " " +
          logDetails(x)
      };
      entryMap = function(a,e){
        // a.head() is array of entries; a[1] is whether last entry is eats
        eats = e{"msg"} == "event added to schedule"
        a[1] && eats
          => [a.head(),true] // omit an eats
           | [a.head().append(episode_line(e)),eats]
      }
      episodes = ctx:logs()
        .collect(function(e){e.get("txnId")})
      episodes.keys()
        .map(function(k){
          episode = episodes.get(k)
          entries = episode
            .reduce(entryMap,[[],false]).head()
          return {
            "txnId": k,
            "time": episode.head().get("time"),
            "header": entries.head().split(re# txnQueued #)[1],
            "entries": entries,
          }
        })
        .filter(omit_common)
        .reverse()
    }
  }
/*
* Rules
*/
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
  rule initSettings {
    select when org_picostack_logging factory_reset
    fired {
//      ent:episodes := logs()
      ent:omitQuery := [
        re#^QUERY .*io.picolabs.pico-engine-ui/#,
        re#^QUERY .*io.picolabs.subscription/established#,
      ]
    }
  }
}

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
ul#logging-list label {
  cursor: pointer;
}
ul#logging-list li input[type="checkbox"]:checked ~ .logging-detail {
  display: block;
}
.logging-detail {
  margin: 0 0 0 18px;
  display: none;
}
.logging-detail span {
  cursor: pointer;
}
</style>
>>
    log_entry = function(entry){
      eats = " event added to schedule "
      parts = entry.split(eats)
      parts.length() == 1 => entry
      | parts[0] + eats + "<span onclick='shwj(event)'>" + parts[1] + "</span>"
    }
    log_li = function(episode,index){
      key = episode{"time"} + " - " + episode{"header"}
      entries = episode{"entries"}
      <<<li>
  <input type="checkbox" id="episode-#{index}" title="#{entries.length()}">
  <label for="episode-#{index}">#{key}</label>
  <pre class="logging-detail">#{entries.map(log_entry).join(chr(10))}
</pre>
</li>
>>
    }
    log = function(_headers){
      the_logs = logs()
      episodes = the_logs.length() <= ent:count
        => the_logs | the_logs.slice(0,ent:count-1)
      html:header("manage logs",styles,null,null,_headers)
      + <<
<h1
  style="float:right;cursor:pointer"
  title="Settings"
  onclick="location='settings.html'">⚙</h1>
<h1>Manage logs</h1>
<ul id="logging-list">
#{episodes.map(log_li).join("")}</ul>
<script type="text/javascript">
function shwj(event){
  alert(JSON.stringify(JSON.parse(event.target.textContent),undefined,2));
}
</script>
>>
      + html:footer()
    }
/*
* Page: settings.html
*/
    settings = function(_headers){
      html:header("manage logs",styles,null,null,_headers)
      + <<
<h1>Manage logging settings</h1>
<h2>Omit queries matching:</h2>
<pre><code>#{ent:omitQuery.map(oqs).values().join(chr(10))}</code></pre>
<h2>Display how many episodes</h2>
<pre><code>#{ent:count}</pre><code>
>>
      + html:footer()
    }
/*
* Internal: logs function
*/
    oqs = function(v,k){
      k + "/" + (v => v | ".*")
    }
    logs = function(){
      toRegExpAtEnd = function(s){(s+"$").as("RegExp")}
      omitQueryREs = ent:omitQuery.map(oqs).values().map(toRegExpAtEnd)
      keep_all_but_common_queries = function(g){
        hdrs = g.get("header") // QUERY ECI RID/NAME ARGS
          .split(" ")
        hdrs.head() != "QUERY"
          || omitQueryREs.none(function(re){hdrs[2].match(re)})
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
        .filter(keep_all_but_common_queries)
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
      ent:omitQuery := {
        "io.picolabs.pico-engine-ui": "",
        "io.picolabs.subscription": "established",
      }
      ent:count := 20
    }
  }
}

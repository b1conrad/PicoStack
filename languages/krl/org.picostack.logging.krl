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
>>
      + modal_html
      + html:footer()
    }
/*
* Page: settings.html
*/
    settings = function(_headers){
      url = <<#{meta:host}/sky/event/#{meta:eci}/none/#{event_domain}/new_settings>>
      html:header("manage logs",styles,null,null,_headers)
      + <<
<h1>Manage logging settings</h1>
<h2>Omit queries matching:</h2>
<pre><code>#{ent:omitQuery.map(oqs).values().join(chr(10))}</code></pre>
<h2>Display how many episodes</h2>
<form action="#{url}">
<input type="number" name="count" value="#{ent:count}" min="10"><br>
<button type="submit">Apply changes</button>
<button onclick="location=document.referrer;return false">Cancel</button>
</form>
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
/*
* Modal box to display JSON
*/
    modal_html = <<
<style>
#modal {
  background-color: #F1F0EC;
  position: fixed; top: 50%; left: 50%;
  transform: translate(-50%,-50%) scale(0);
  width: 800px; max-width: 80%;
  border: 1px solid black; border-radius: 10px;
  transition: 300ms ease-in-out;
  overflow-y: scroll; max-height: 80%
}
#modal.active {
  transform: translate(-50%,-50%) scale(1);
}
#modal-close {
  float: right; cursor: pointer;
  border: none; background: none;
  font-size: 1.25rem; font-weight: bold;
}
#modal-pre {
  overflow: overlay;
  padding: 0 5px;
  background-color: #F1F0EC;
}
#shadow {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,.5); opacity: 0;
  pointer-events: none;
  transition: 300ms ease-in-out;
}
#shadow.active {
  opacity: 0.5;
  pointer-events: all;
}
</style>
<div id="shadow" onclick="clearModal()"></div>
<div id="modal">
  <button id="modal-close" onclick="clearModal()">&times;</button>
  <pre id="modal-pre"></pre>
</div>

<script type="text/javascript">
const the_modal_pre = document.getElementById('modal-pre');
const the_modal = document.getElementById('modal');
const the_shadow = document.getElementById('shadow');
function shwj(event){
  var j = JSON.stringify(JSON.parse(event.target.textContent),undefined,2);
  the_modal_pre.textContent = j;
  the_modal.classList.add('active');
  the_shadow.classList.add('active');
}
function clearModal(){
  the_shadow.classList.remove('active');
  the_modal.classList.remove('active');
}
</script>
>>
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
  rule applySettings {
    select when org_picostack_logging new_settings
      count re#^(\d\d+)$#
      setting(new_count)
    pre {
      log_url = <<#{meta:host}/c/#{meta:eci}/query/#{meta:rid}/log.html>>
    }
    send_directive("_redirect",{"url":log_url})
    fired {
      ent:count := new_count
      raise org_picostack_logging event "settings_changed" attributes event:attrs
    }
  }
}

ruleset io.picolabs.plan.wovyn-monitor {
  meta {
    name "counts"
    use module io.picolabs.plan.apps alias app
    shares count
  }
  global {
    display_counts = function(cs){
      cs.map(function(v,k){
        <<#{k}: #{v}<br>
>>
      }).values().join("")
    }
    count = function(_headers){
      app:html_page("manage counts", "",
<<
<h1>Manage counts</h1>
#{display_counts(ent:counts)}
<form action="#{app:event_url(meta:rid,"manual_reset")}">
<button type="submit">reset</button>
</form>
<p>How many checks ok? #{ent:checks_ok.defaultsTo(0)}</p>
<p>Last check ok at: #{ent:last_check_ok_at.defaultsTo("N/A")}</p>
<p>How many checks failed? #{ent:checks_failed.defaultsTo(0)}</p>
<p>Last alert sent at: #{ent:last_alert_sent.defaultsTo("N/A")}</p>
<p>Counts when alert sent:<br>
#{display_counts(ent:last_alert_counts)}</p>
>>, _headers)
    }
  }
  rule initialize {
    select when io_picolabs_plan_wovyn_monitor factory_reset
    fired {
      ent:counts := {}
    }
  }
  rule count {
    select when io_picolabs_plan_wovyn_sensors:temp_recorded
      name re#(.+)# setting(local_name)
    fired {
      ent:counts{local_name} := ent:counts{local_name}.defaultsTo(0) + 1
    }
  }
  rule hourlyCheck {
    select when time top_of_the_hour
    if ent:counts.values().any(function(v){v==0}) then noop()
    fired {
      raise io_picolabs_plan_wovyn_monitor event "check_failed"
        attributes {"counts":ent:counts.map(function(v){v})}
    } else {
      ent:checks_ok := ent:checks_ok.defaultsTo(0) + 1
      ent:last_check_ok_at := time:now()
    }
  }
  rule resetCounts {
    select when io_picolabs_plan_wovyn_monitor manual_reset
             or time top_of_the_hour
    fired {
      ent:counts := ent:counts.map(function(v,k){0})
    }
  }
  rule redirectToHomePage {
    select when io_picolabs_plan_wovyn_monitor manual_reset
    send_directive("_redirect",{"url":app:query_url(meta:rid,"count.html")})
  }
  rule notifyFailedCheck {
    select when io_picolabs_plan_wovyn_monitor check_failed
    fired {
      ent:checks_failed := ent:checks_failed.defaultsTo(0) + 1
      ent:last_alert_counts := event:attrs{"counts"}
      ent:last_alert_sent := time:now()
    }
  }
}

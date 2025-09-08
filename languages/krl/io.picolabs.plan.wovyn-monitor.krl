ruleset io.picolabs.plan.wovyn-monitor {
  meta {
    name "counts"
    use module io.picolabs.plan.apps alias app
    shares count
  }
  global {
    count = function(_headers){
      app:html_page("manage counts", "",
<<
<h1>Manage counts</h1>
#{ent:counts.map(function(v,k){
  <<#{k}: #{v}<br>
>>
}).values().join("")}
<form action="#{app:event_url(meta:rid,"manual_reset")}">
<button type="submit">reset</button>
</form>
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
  rule resetCounts {
    select when io_picolabs_plan_wovyn_monitor manual_reset
    fired {
      ent:counts := ent:counts.map(function(v,k){0})
    }
  }
  rule redirectToHomePage {
    select when io_picolabs_plan_wovyn_monitor manual_reset
    send_directive("_redirect",{"url":app:query_url(meta:rid,"count.html")})
  }
}

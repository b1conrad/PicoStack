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
      local_name re#(.+)# setting(local_name)
    fired {
      ent:counts{local_name} := ent:counts{local_name}.defaultsTo(0) + 1
    }
  }
}

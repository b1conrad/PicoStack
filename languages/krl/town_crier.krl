ruleset town_crier {
  meta {
    name "times"
    use module io.picolabs.plan.apps alias app
    shares time
  }
  global {
    time = function(_headers){
      app:html_page("manage times", "",
<<
<h1>Manage times</h1>
<dl>
  <dt>Time installed</dt>
  <dd>#{ent:time_installed}</dd>
  <dt>Time last hour</dt>
  <dd>#{ent:time_last_hour}</dd>
  <dt>Time currently</dt>
  <dd>#{time:now()}</dd>
</dl>
<h2>Technical</h2>
<p>ent:id = #{ent:id.encode()}</p>
#{schedule:list().map(function(v){
  <<<pre>#{v.encode()}</pre>
>>}).join("")}
>>, _headers)
    }
  }
  rule start {
    select when town_crier factory_reset
    fired {
      ent:time_installed := time:now()
      schedule time event "top_of_the_hour"
        repeat << 0 * * * * >>  attributes { } setting(id)
      ent:id := id.typeof()=="Map" => id{"id"} | id
    }
  }
  rule hearTheCry {
    select when time top_of_the_hour
    fired {
      ent:time_last_hour := time:now()
    }
  }
  rule cleanUpOldSchedules {
    select when town_crier cleanup_needed
    foreach schedule:list() setting(sched)
    if sched{"id"} != ent:id then
      schedule:remove(sched{"id"})
  }
}

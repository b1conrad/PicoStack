ruleset org.picostack.calc_age {
  meta {
    name "age_calcs"
    use module io.picolabs.wrangler alias wrangler
    use module html
    shares age_calc, url_test
  }
  global {
    YEAR_NOW = 2023
    event_domain = "org_picostack_calc_age"
    age_calc = function(_headers){
      url_base = <<#{meta:host}/sky/event/#{meta:eci}/none/#{event_domain}>>
      url_calc = <<#{url_base}/new_inputs>>
      url_clear = <<#{url_base}/inputs_not_needed>>
      val_name = ent:name => << value="#{ent:name}">> | ""
      val_year = ent:year => << value="#{ent:year}">> | ""
      html:header("manage age_calcs","",_headers)
      + <<
<h1>Manage age_calcs</h1>
<form action="#{url_calc}">
  Enter your name: 
  <input name="name" maxlength="80" required#{val_name}>
  <br>
  Enter the year of your birth.
  <input name="year" type="number" maxlength="80" required#{val_year}>
  <br>
  <button type="submit">Submit</button> // was Press any key to continue.
</form>
#{ent:name && ent:age => <<
<p>
#{ent:name}, your age is #{ent:age}.
<a href="#{url_clear}">clear</a>
</p>
>> | ""}
>>
      + html:footer()
    }
    ageCalc = function(birthYear){
      the_birth_year = birthYear.klog("year passed =")
        .split("").reduce(function(a,d){a*10+d.as("Number")},0)
      diff = YEAR_NOW - the_birth_year // was 2003 - birthYear
      diff
    }
    url_test = function(){
      <<#{meta:host}/c/#{meta:eci}/query/#{meta:rid}/age_calc.html>>
    }
  }
  rule calculateAge {
    select when org_picostack_calc_age new_inputs
      name re#^(.+)$#
      year re#^(\d+)$#
      setting(name,year)
    fired {
      ent:name := name
      ent:year := year
      ent:age := ageCalc(year)
    }
  }
  rule clearInputs {
    select when org_picostack_calc_age inputs_not_needed
    fired {
      clear ent:name
      clear ent:year
      clear ent:age
    }
  }
  rule redirectBack {
    select when org_picostack_calc_age new_inputs
             or org_picostack_calc_age inputs_not_needed
    pre {
      referrer = event:attr("_headers").get("referer") // [sic]
    }
    if referrer then send_directive("_redirect",{"url":referrer})
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["age_calcs"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise org_picostack_calc_age event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when org_picostack_calc_age factory_reset
    foreach wrangler:channels(["age_calcs"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
}

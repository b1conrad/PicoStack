ruleset demo3 {
  meta {
    use module sdk
  }
  rule makeItHappen {
    select when demo work_needed
    every {
      event:send({"eci":meta:eci,"domain":"sdk","type":"might_need_a_valid_token"})
      event:send({"eci":meta:eci,"domain":"demo","type":"work_needed_using_token",
        "attrs":event:attrs})
    }
  }
  rule reallyMakeItHappen {
    select when demo work_needed_using_token
    sdk:takeAction() setting(response)
    fired {
      raise demo event "real_work_done"
        attributes event:attrs.put("response",response)
    }
  }
}

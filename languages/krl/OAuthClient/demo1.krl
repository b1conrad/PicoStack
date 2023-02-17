ruleset demo1 {
  meta {
    use module sdk
  }
  rule makeItHappen {
    select when demo work_needed
    fired {
      raise sdk event "might_need_a_valid_token"
    }
  }
  rule reallyMakeItHappen {
    select when demo work_needed
    sdk:takeAction() setting(response)
    fired {
      raise demo event "real_work_done"
        attributes event:attrs.put("response",response)
    }
  }
}

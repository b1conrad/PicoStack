ruleset demo2 {
  meta {
    use module sdk
  }
  rule makeItHappen {
    select when demo work_needed
    fired {
      raise sdk event "might_need_a_valid_token"
      raise demo event "work_needed_using_token"
        attributes event:attrs
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

ruleset com.mailjet.sdk {
  meta {
    provides send
  }
  global {
    api_key = meta:rulesetConfig{"api_key"}
    secret_key = meta:rulesetConfig{"secret_key"}
    send = defaction(){
      url = <<https://#{api_key}:#{secret_key}@api.mailjet.com/v3.1/send>>
      content = {
"Messages":[
    {
      "From": {
        "Email": "mailjet@sanbachs.com",
        "Name": "Bruce"
      },
      "To": [
        {
          "Email": "mailjet@sanbachs.com",
          "Name": "Bruce"
        }
      ],
      "Subject": "My first Mailjet email",
      "TextPart": "Greetings from Mailjet.",
      "HTMLPart": "<h3>Dear passenger 1, welcome to <a href='https://www.mailjet.com/'>Mailjet</a>!</h3><br />May the delivery force be with you!",
      "CustomID": "AppGettingStartedTest"
    }
  ]
}
      http:post(url,json=content) setting(response)
      return response
    }
  }
}

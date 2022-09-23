ruleset com.mailjet.sdk {
  meta {
    provides send
  }
  global {
    api_key = meta:rulesetConfig{"api_key"}
    secret_key = meta:rulesetConfig{"secret_key"}
    creds = {"username":api_key,"password":secret_key}
    email = meta:rulesetConfig{"email"}
    send = defaction(){
      url = <<https://api.mailjet.com/v3.1/send>>
      content = {
  "Messages":[
    {
      "From": {
        "Email": email,
        "Name": "Bruce"
      },
      "To": [
        {
          "Email": email,
          "Name": "Bruce"
        }
      ],
      "Subject": "My first Mailjet email",
      "TextPart": "Greetings from Mailjet.",
      "HTMLPart": "<h3>Dear passenger 1, welcome to <a href='https://www.mailjet.com/'>Mailjet</a>!</h3><br />May the delivery force be with you!",
      "CustomID": "AppGettingStartedTest"
    }
  ]}
      http:post(url,auth=creds,json=content) setting(response)
      return response
    }
  }
}

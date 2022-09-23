ruleset com.mailjet.sdk {
  meta {
    provides send_first, send_text
  }
  global {
    api_key = meta:rulesetConfig{"api_key"}
    secret_key = meta:rulesetConfig{"secret_key"}
    basic = {"username":api_key,"password":secret_key}
    email = meta:rulesetConfig{"email"}
    from_name = meta:rulesetConfig{"name"}
    send_url = "https://api.mailjet.com/v3.1/send"
    send_text = defaction(to,subject,text){
      msg = {
        "From":{"Email":email,"Name":from_name},
        "To": [{"Email":to}],
        "Subject": subject,
        "TextPart": text || "",
      }
      msgs = {}.put("Messages",[msg])
      http:post(send_url,auth=basic,json=msgs) setting(response)
      return response
    }
    send_first = defaction(name){
      msgs =
// copy JSON from app.mailjet.com/auth/get_started/developer
// plugging in values for "Email" and "Name"
{
  "Messages":[
    {
      "From": {
        "Email": email,
        "Name": from_name
      },
      "To": [
        {
          "Email": email,
          "Name": from_name
        }
      ],
      "Subject": "My first Mailjet email",
      "TextPart": "Greetings from Mailjet.",
      "HTMLPart": "<h3>Dear passenger 1, welcome to <a href='https://www.mailjet.com/'>Mailjet</a>!</h3><br />May the delivery force be with you!",
      "CustomID": "AppGettingStartedTest"
    }
  ]
}
// end JSON copy from mailjet; retrieved 2022/09/23
      http:post(send_url,auth=basic,json=msgs) setting(response)
      return response
    }
  }
}

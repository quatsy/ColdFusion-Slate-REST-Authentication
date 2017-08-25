# ColdFusion-Slate-REST-Authentication

Built by Jason Quatrino for Hamilton College on 8/25/2017 based on Slate REST Authentication Documentation found at:

https://technolutions.zendesk.com/hc/en-us/articles/216174348-Slate-authentication-service#article-comments

Instructions:

1. Save auth.cfc to your working copy.
2. Open file and update "requestURL" variable to use your secure (SSL) Slate domain, e.g.: "https://admission.mycollege.edu/". Include trailing slash.
3. Update "cfc.path.to.auth" to your CFC path.
4. Authenticate as follows:

  <cfset request.slateAuth =  createObject("component","cfc.path.to.auth")
  .authUser(username=form.username,password=form.password) />
  
  authUser() returns a ColdFusion Struct containing "isAuth" boolean, "msg" string, and raw "slateData" results struct.
  
  Enjoy!

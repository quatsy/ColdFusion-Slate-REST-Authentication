<cfcomponent hint="Slate REST authentication integration" output="false">

	<!--- Built by Jason Quatrino on 8/25/2017 based on Slate REST Authentication Documentation found at:

		https://technolutions.zendesk.com/hc/en-us/articles/216174348-Slate-authentication-service#article-comments

	--->

	<cfset requestURL = "https://your.SlateDomain.here/" />

	<cffunction name="authUser" returntype="struct" output="true">
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />

		<cfset local.results = {} />
		<cfset local.results.msg = "" />
		<cfset local.results.isAuth = false />
		<cfset local.results.slateData = {} />

		<cfif Len(arguments.username)>
			<cfif Len(arguments.password)>
				<cftry>
					<cfhttp url="#requestURL#account/rest/login" method="post" result="local.httpResult">
						<cfhttpparam type="url" name="user" value="#arguments.username#" />
						<cfhttpparam type="url" name="password" value="#arguments.password#" />
					</cfhttp>

					<cfcatch type="any">
						<cfset local.results.msg &= "AuthUser HTTP ERROR: #cfcatch.message#" />
						<cfreturn results />
					</cfcatch>
				</cftry>

				<cfif structKeyExists(local.httpResult,"errordetail") AND Len(local.httpResult.errordetail)>
					<cfset local.results.msg &= "AuthUser HTTP ERROR: #local.httpResult.errordetail#" />
				<cfelse>
					<cfif structKeyExists(local.httpResult,"filecontent") AND Len(local.httpResult.filecontent)>
						<cfif isValid("xml",local.httpResult.filecontent)>
							<!--- parse results --->
							<cfset local.results.slateData = parseSlateXML(XMLParse(local.httpResult.filecontent)) />

							<!--- expected xml results:
								status = "SUCCESS" - (id/ref/status/user)
								status = "ERROR" - (message,status)
							--->
							
							<cfset local.results.isAuth = isSuccessfulLogin(local.results.slateData.status) />
							<cfset local.results.msg &= local.results.slateData.status />

							<cfif StructKeyExists(local.results.slateData,"message")>
								<cfset local.results.msg &= ": #local.results.slateData.message#" />
							</cfif>
						<cfelse>
							<cfset local.results.msg &= " AuthUser File Content ERROR: Invalid XML." />
						</cfif>
					<cfelse>
						<cfset local.results.msg &= " AuthUser File Content ERROR: Unexpected result." />
					</cfif>
				</cfif>
			<cfelse>
				<cfset local.results.msg &= " AuthUser Argument ERROR: password is required." />
			</cfif>
		<cfelse>
			<cfset local.results.msg &= " AuthUser Argument ERROR: username is required." />
		</cfif>

		<cfreturn local.results />
	</cffunction>

	<cffunction name="parseSlateXML" returntype="struct" output="false">
		<cfargument name="slateXML" type="xml" required="true" />

		<cfset local.slateResults = {} />
		<cfset local.slateResults.status = "" /><!--- ensure that results always have a status. referenced to determine successful authentication --->
		<cfset local.resultNodes = arguments.slateXML.result />

		<cfloop array="#local.resultNodes.XMLChildren#" item="i">
			<cfset local.slateResults[i.xmlName] = i.xmlText />
		</cfloop>

		<cfreturn local.slateResults />
	</cffunction>

	<cffunction name="isSuccessfulLogin" returntype="boolean" output="false">
		<cfargument name="slatestatus" type="string" required="true" /><!--- success/error flag from Slate --->

		<cfreturn (arguments.slatestatus == "SUCCESS" ? true : false) />
	</cffunction>
</cfcomponent>
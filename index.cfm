﻿<!---
/**
 * OWASP Enterprise Security API (ESAPI)
 *
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2011 - The OWASP Foundation
 *
 * The ESAPI is published by OWASP under the BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 *
 * @author Damon Miller
 * @created 2011
 */
--->

<cfscript>
	ESAPI = createObject("component", "org.owasp.esapi.ESAPI");

	serverVersion = "CF " & server.coldfusion.ProductVersion;
	if(structKeyExists(server, "railo")) {
		serverVersion = "Railo " & server.railo.version;
	}
</cfscript>

<cfoutput>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>#ESAPI.ESAPINAME# #ESAPI.VERSION# [#serverVersion#]</title>
</head>
<body>

<h1>ESAPI for ColdFusion/CFML (#ESAPI.ESAPINAME#)</h1>
<ul>
	<li><strong>CFML Server:</strong> #serverVersion#</li>
	<li><strong>#ESAPI.ESAPINAME# Version:</strong> #ESAPI.VERSION#</li>
	<li><strong>ESAPI4J Version:</strong> #ESAPI.ESAPI4JVERSION#</li>
</ul>
<p>Please refer to the <a href="http://damonmiller.github.io/esapi4cf/">#ESAPI.ESAPINAME# GitHub.io pages</a> for more information.</p>

<h2>Tests</h2>
<dl>
	<dt><a href="test/org/owasp/esapi/AllTests.cfm">Unit Tests</a></dt>
	<dd>The ESAPI Unit Tests ported into ColdFusion/CFML using MXUnit (not included).</dd>
</dl>

<h2>Utilities</h2>
<dl>
	<dt><a href="utilities/DefaultEncryptedProperties.cfm">Encrypted Properties files</a></dt>
	<dd>Loads encrypted properties file based on the location passed in args then prompts the user to input key-value pairs.</dd>
	<dt><a href="utilities/FileBasedAuthenticator.cfm">Fail safe main program to add or update an account in an emergency</a></dt>
	<dd>WARNING: this method does not perform the level of validation and checks generally required in ESAPI, and can therefore be used to create a username and password that do not comply with the username and password strength requirements.</dd>
</dl>

<h2>Samples</h2>
<dl>
	<dt><a href="samples/tutorials/">Tutorials Code</a></dt>
	<dd>This is the sample code referenced by the <a href="http://damonmiller.github.io/esapi4cf/tutorials/Introduction.html">#ESAPI.ESAPINAME# tutorials</a>.</dd>
	<!--- <dt><a href="samples/rest-taffy/">REST with Taffy</a></dt>
	<dd>Example of how to implement #ESAPI.ESAPINAME# with Taffy REST framework (not included).</dd> --->
</dl>

</body>
</html>
</cfoutput>
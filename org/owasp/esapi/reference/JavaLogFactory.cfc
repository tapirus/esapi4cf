<!---
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
<cfcomponent implements="org.owasp.esapi.LogFactory" extends="org.owasp.esapi.util.Object" output="false" hint="Reference implementation of the LogFactory and Logger interfaces. This implementation uses the Java logging package, and marks each log message with the currently logged in user and the word 'SECURITY' for security related events. See the JavaLogFactory.JavaLogger Javadocs for the details on the JavaLogger reference implementation.">

	<cfscript>
		variables.ESAPI = "";
		variables.applicationName = "";

		variables.loggersMap = {};
	</cfscript>

	<cffunction access="public" returntype="org.owasp.esapi.LogFactory" name="init" output="false"
	            hint="Constructor for this implementation of the LogFactory interface.">
		<cfargument required="true" type="org.owasp.esapi.ESAPI" name="ESAPI"/>
		<cfargument required="true" type="String" name="applicationName" hint="The name of this application this logger is being constructed for."/>

		<cfscript>
			variables.ESAPI = arguments.ESAPI;
			variables.applicationName = applicationName;
			return this;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="org.owasp.esapi.Logger" name="getLogger" output="false">
		<cfargument required="true" type="String" name="moduleName"/>

		<cfscript>
			var moduleLogger = "";
			// If a logger for this module already exists, we return the same one, otherwise we create a new one.
			if(structKeyExists(variables.loggersMap, arguments.moduleName)) {
				moduleLogger = variables.loggersMap.get(arguments.moduleName);
			}
			if(isNull(moduleLogger) || !isObject(moduleLogger)) {
				moduleLogger = createObject("component", "JavaLogFactory$JavaLogger").init(variables.ESAPI, variables.applicationName, arguments.moduleName);
				variables.loggersMap.put(arguments.moduleName, moduleLogger);
			}
			return moduleLogger;
		</cfscript>

	</cffunction>

</cfcomponent>
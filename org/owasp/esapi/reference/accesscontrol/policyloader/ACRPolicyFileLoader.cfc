<cfcomponent extends="cfesapi.org.owasp.esapi.util.Object" output="false">

	<cfscript>
		Logger = javaLoader().create("org.owasp.esapi.Logger");

		instance.ESAPI = "";
		instance.logger = "";
	</cfscript>

	<cffunction access="public" returntype="ACRPolicyFileLoader" name="init" output="false">
		<cfargument type="cfesapi.org.owasp.esapi.ESAPI" name="ESAPI" required="true">
		<cfscript>
			instance.ESAPI = arguments.ESAPI;
			instance.logger = instance.ESAPI.getLogger("ACRPolicyFileLoader");

			return this;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="PolicyDTO" name="load" output="false">
		<cfscript>
			local.policyDTO = createObject("component", "PolicyDTO").init(instance.ESAPI);
			local.config = "";
			local.file = instance.ESAPI.securityConfiguration().getResourceFile("ESAPI-AccessControlPolicy.xml");
			try {
			    local.config = javaLoader().create("org.apache.commons.configuration.XMLConfiguration").init(local.file);
			}
			catch(org.apache.commons.configuration.ConfigurationException cex) {
				if(local.file == "") {
					cfex = createObject("component", "cfesapi.org.owasp.esapi.errors.AccessControlException").init(instance.ESAPI, "Unable to load configuration file for the following: " & "ESAPI-AccessControlPolicy.xml", "", cex);
            		throw(message=cfex.getMessage(), type=cfex.getType());
				}
			    cfex = createObject("component", "cfesapi.org.owasp.esapi.errors.AccessControlException").init(instance.ESAPI, "Unable to load configuration file from the following location: " & local.file.getAbsolutePath(), "", cex);
            	throw(message=cfex.getMessage(), type=cfex.getType());
			}

			local.property = local.config.getProperty("AccessControlRules.AccessControlRule[@name]");
			instance.logger.info(Logger.EVENT_SUCCESS, "Loading Property: " & local.property.toString());
			local.numberOfRules = 0;
			if(isInstanceOf(local.property, "java.util.Collection")) {
				local.numberOfRules = local.property.size();
			} //implied else property == null -> return new PolicyDTO

			local.ruleName = "";
			local.ruleClass = "";
			local.rulePolicyParameter = "";
			local.currentRule = 0;
		    try {
		    	instance.logger.info(Logger.EVENT_SUCCESS, "Number of rules: " & local.numberOfRules);
				for(local.currentRule = 0; local.currentRule < local.numberOfRules; local.currentRule++) {
					instance.logger.trace(Logger.EVENT_SUCCESS, "----");
					local.ruleName = local.config.getString("AccessControlRules.AccessControlRule(" & local.currentRule & ")[@name]");
					instance.logger.trace(Logger.EVENT_SUCCESS, "Rule name: " & local.ruleName);
					local.ruleClass = local.config.getString("AccessControlRules.AccessControlRule(" & local.currentRule & ")[@class]");
					instance.logger.trace(Logger.EVENT_SUCCESS, "Rule Class: " & local.ruleClass);
					local.rulePolicyParameter = getPolicyParameter(local.config, local.currentRule);
					instance.logger.trace(Logger.EVENT_SUCCESS, "rulePolicyParameters: " & local.rulePolicyParameter.toString());
					local.policyDTO.addAccessControlRule( local.ruleName, local.ruleClass, local.rulePolicyParameter );
				}
				instance.logger.info(Logger.EVENT_SUCCESS, "policyDTO loaded: " & local.policyDTO.toString());
			} catch (cfesapi.org.owasp.esapi.errors.AccessControlException e) {
				cfex = createObject("component", "cfesapi.org.owasp.esapi.errors.AccessControlException").init(instance.ESAPI, "Unable to load AccessControlRule parameter. " &
					" Rule number: " & local.currentRule &
					" Probably: Rule.name: " & local.ruleName &
					" Probably: Rule.class: " & local.ruleClass &
					" " & e.getMessage(), "", e);
           		throw(message=cfex.getMessage(), type=cfex.getType());
			}
			return local.policyDTO;
		</cfscript>
	</cffunction>


	<cffunction access="private" returntype="any" name="getPolicyParameter" output="false">
		<cfargument type="any" name="config" required="true" hint="org.apache.commons.configuration.XMLConfiguration">
		<cfargument type="numeric" name="currentRule" required="true">
		<cfscript>
			//If there aren't any properties: short circuit and return null.
	//		Properties tempParameters = config.getProperties("AccessControlRules.AccessControlRule(" + currentRule + ").Parameters.Parameter[@name]");
			local.property = arguments.config.getProperty("AccessControlRules.AccessControlRule(" & arguments.currentRule & ").Parameters.Parameter[@name]");
			if(isNull(local.property)) {
				return "";
			}

			local.numberOfProperties = 0;
			if(isInstanceOf(local.property, "java.util.Collection")) {
				local.numberOfProperties = local.property.size();
			} else {
				local.numberOfProperties = 1;
			}
			instance.logger.info(Logger.EVENT_SUCCESS, "Number of properties: " & local.numberOfProperties);

			if(local.numberOfProperties < 1) {
				return "";
			}
			local.parametersLoaderClassName = arguments.config.getString("AccessControlRules.AccessControlRule(" & arguments.currentRule & ").Parameters[@parametersLoader]");
			if(isNull(local.parametersLoaderClassName) || "" == local.parametersLoaderClassName) {
				//this default should have a properties file override option
				local.parametersLoaderClassName = "cfesapi.org.owasp.esapi.reference.accesscontrol.policyloader.DynaBeanACRParameterLoader";
			}
			instance.logger.info(Logger.EVENT_SUCCESS, "Parameters Loader:" & local.parametersLoaderClassName);
			local.acrParamaterLoader = createObject("component", local.parametersLoaderClassName).init(instance.ESAPI);
			return local.acrParamaterLoader.getParameters(arguments.config, arguments.currentRule);
		</cfscript>
	</cffunction>


</cfcomponent>
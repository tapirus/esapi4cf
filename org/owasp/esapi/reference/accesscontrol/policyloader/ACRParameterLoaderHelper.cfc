<cfcomponent output="false">


	<cffunction access="public" returntype="any" name="getParameterValue" output="false">
		<cfargument type="any" name="config" required="true" hint="org.apache.commons.configuration.XMLConfiguration">
		<cfargument type="numeric" name="currentRule" required="true">
		<cfargument type="numeric" name="currentParameter" required="true">
		<cfargument type="String" name="parameterType" required="true">
		<cfscript>
			local.key = "AccessControlRules.AccessControlRule(" & arguments.currentRule & ").Parameters.Parameter(" & arguments.currentParameter & ")[@value]";
			local.parameterValue = "";
			if("String" == arguments.parameterType) {
				local.parameterValue = arguments.config.getString(local.key);
			} else if("StringArray" == arguments.parameterType) {
				local.parameterValue = arguments.config.getStringArray(local.key);
			} else if("Boolean" == arguments.parameterType){
				local.parameterValue = arguments.config.getBoolean(local.key);
			} else if("Byte" == arguments.parameterType){
				local.parameterValue = arguments.config.getByte(local.key);
			} else if("Int" == arguments.parameterType){
				local.parameterValue = arguments.config.getInt(local.key);
			} else if("Long" == arguments.parameterType){
				local.parameterValue = arguments.config.getLong(local.key);
			} else if("Float" == arguments.parameterType){
				local.parameterValue = arguments.config.getFloat(local.key);
			} else if("Double" == arguments.parameterType){
				local.parameterValue = arguments.config.getDouble(local.key);
			} else if("BigDecimal" == arguments.parameterType){
				local.parameterValue = arguments.config.getBigDecimal(local.key);
			} else if("BigInteger" == arguments.parameterType){
				local.parameterValue = arguments.config.getBigInteger(local.key);
			} else if("Date" == arguments.parameterType){
				local.parameterValue = createObject("java", "java.text.DateFormat").getDateInstance().parse(arguments.config.getString(local.key));
			} else if("Time" == arguments.parameterType){
				local.sdf = createObject("java", "java.text.SimpleDateFormat").init("h:mm a");
				local.parameterValue = local.sdf.parseObject(arguments.config.getString(local.key));
	//			local.parameterValue = java.text.DateFormat.getTimeInstance().parse(arguments.config.getString(key));
			}
			//add timestamp. check for other stuff.
			else {
				throw(object=createObject("java", "java.lang.IllegalArgumentException").init('Unable to load the key "' & local.key & '", because the type "' & arguments.parameterType & '" was not recognized.' ));
			}
			return local.parameterValue;
		</cfscript>
	</cffunction>


</cfcomponent>

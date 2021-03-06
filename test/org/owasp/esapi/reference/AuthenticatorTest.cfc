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
<cfcomponent extends="esapi4cf.test.org.owasp.esapi.util.TestCase" output="false">

	<cfscript>
		clearUserFile();
	</cfscript>

	<cffunction access="public" returntype="void" name="testCreateUser" output="false"
	            hint="Test of createAccount method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var accountName = "";
			var instance = "";
			var password = "";
			var user = "";

			System.out.println("createUser");
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			instance = request.ESAPI.authenticator();
			password = instance.generateStrongPassword();
			user = instance.createUser(accountName, password, password);
			assertTrue(user.verifyPassword(password));
			try {
				instance.createUser(accountName, password, password);// duplicate user
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationAccountsException e) {
				// success
			}
			try {
				instance.createUser(request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS), "password1", "password2");// don't match
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				instance.createUser(request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS), "weak1", "weak1");// weak password
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				// Railo 4.1 has full NULL support
				instance.createUser(javaCast("null", ""), "weak1", "weak1");// null username
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationAccountsException e) {
				// success
			}
			catch(application e) {
				// fails if NULL support is not available - just skip
			}
			try {
				// Railo 4.1 has full NULL support
				instance.createUser(request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS), javaCast("null", ""), javaCast("null", ""));// null password
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			catch(application e) {
				// fails if NULL support is not available - just skip
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGenerateStrongPassword" output="false"
	            hint="Test of generateStrongPassword method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var oldPassword = "";
			var newPassword = "";
			var username = "";
			var user = "";
			var i = "";

			System.out.println("generateStrongPassword");
			instance = request.ESAPI.authenticator();
			oldPassword = "iiiiiiiiii";// i is not allowed in passwords - this prevents failures from containing pieces of old password
			newPassword = "";
			username = "FictionalEsapiUser";
			user = createObject("component", "org.owasp.esapi.reference.DefaultUser").init(request.ESAPI, username);
			for(i = 0; i < 100; i++) {
				try {
					newPassword = instance.generateStrongPassword();
					instance.verifyPasswordStrength(oldPassword, newPassword, user);
				}
				catch(org.owasp.esapi.errors.AuthenticationException e) {
					System.out.println("  FAILED >> " & newPassword & " : " & e.getLogMessage());
					fail("");
				}
			}

			try {
				instance.verifyPasswordStrength("test56^$test", "abcdx56^$sl", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// expected
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetCurrentUser" output="false"
	            hint="Test of getCurrentUser method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var username1 = "";
			var username2 = "";
			var user1 = "";
			var user2 = "";
			var httpRequest = "";
			var httpResponse = "";
			var currentUser = "";

			System.out.println("getCurrentUser");
			instance = request.ESAPI.authenticator();
			username1 = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			username2 = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			user1 = instance.createUser(username1, "getCurrentUser", "getCurrentUser");
			user2 = instance.createUser(username2, "getCurrentUser", "getCurrentUser");
			user1.enable();
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();;
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			user1.loginWithPassword("getCurrentUser");
			currentUser = instance.getCurrentUser();
			assertEquals(currentUser, user1);
			instance.setCurrentUser(user2);
			assertFalse(currentUser.getAccountName() == user2.getAccountName());

			/* TODO: make runnable
			Runnable echo = new Runnable() {
			    private int count = 1;
			    private boolean result = false;
			    public void run() {
			        Authenticator instance = request.ESAPI.authenticator();
			        User a = null;
			        try {
			            String password = instance.generateStrongPassword();
			            String accountName = "TestAccount" + count++;
			            a = instance.getUser(accountName);
			            if ( a != null ) {
			                instance.removeUser(accountName);
			            }
			            a = instance.createUser(accountName, password, password);
			            instance.setCurrentUser(a);
			        } catch (org.owasp.esapi.errors.AuthenticationException e) {
			            e.printStackTrace();
			        }
			        User b = instance.getCurrentUser();
			        result &= a.equals(b);
			    }
			};
			ThreadGroup tg = new ThreadGroup("test");
			for ( int i = 0; i<10; i++ ) {
			    new Thread( tg, echo ).start();
			}
			while (tg.activeCount() > 0 ) {
			    Thread.sleep(100);
			} */
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetUser" output="false"
	            hint="Test of getUser method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var password = "";
			var accountName = "";

			System.out.println("getUser");
			instance = request.ESAPI.authenticator();
			password = instance.generateStrongPassword();
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			instance.createUser(accountName, password, password);
			assertTrue(isObject(instance.getUserByAccountName(accountName)));
			assertFalse(isObject(instance.getUserByAccountName(request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS))));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetUserFromRememberToken" output="false">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var password = "";
			var accountName = "";
			var user = "";
			var httpRequest = "";
			var httpResponse = "";
			var newToken = "";
			var test2 = "";

			System.out.println("getUserFromRememberToken");
			instance = request.ESAPI.authenticator();
			instance.logout();// in case anyone is logged in
			password = instance.generateStrongPassword();
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			user = instance.createUser(accountName, password, password);
			user.enable();
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();;
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);

			httpRequest.setCookie(request.ESAPI.httpUtilities().REMEMBER_TOKEN_COOKIE_NAME, "ridiculous");
			try {
				instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());// wrong cookie will fail
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// expected
			}

			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			request.ESAPI.authenticator().setCurrentUser(user);
			newToken = request.ESAPI.httpUtilities().setRememberToken(request.ESAPI.currentRequest(), request.ESAPI.currentResponse(), password, 10000, "esapi4cf.test.com", httpRequest.getContextPath());
			httpRequest.setCookie(request.ESAPI.httpUtilities().REMEMBER_TOKEN_COOKIE_NAME, newToken);
			test2 = instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());
			assertEquals(user.getAccountName(), test2.getAccountName());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetUserFromSession" output="false"
	            hint="Test get user from session.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var accountName = "";
			var password = "";
			var user = "";
			var httpRequest = "";
			var httpResponse = "";
			var test = "";

			System.out.println("getUserFromSession");
			instance = request.ESAPI.authenticator();
			instance.logout();// in case anyone is logged in
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			password = instance.generateStrongPassword();
			user = instance.createUser(accountName, password, password);
			user.enable();
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpRequest.addParameter("username", accountName);
			httpRequest.addParameter("password", password);
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();;
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());
			test = instance.getUserFromSession();
			assertEquals(user, test);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetUserNames" output="false"
	            hint="Test get user names.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var password = "";
			var testnames = "";
			var i = "";
			var names = "";

			System.out.println("getUserNames");
			instance = request.ESAPI.authenticator();
			password = instance.generateStrongPassword();
			testnames = [];
			arrayResize(testnames, 10);
			for(i = 1; i <= arrayLen(testnames); i++) {
				testnames[i] = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			}
			for(i = 1; i <= arrayLen(testnames); i++) {
				instance.createUser(testnames[i], password, password);
			}
			names = instance.getUserNames();
			for(i = 1; i <= arrayLen(testnames); i++) {
				assertTrue(names.contains(testnames[i].toLowerCase()));
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testHashPassword" output="false"
	            hint="Test of hashPassword method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var username = "";
			var password = "";
			var instance = "";
			var result1 = "";
			var result2 = "";

			System.out.println("hashPassword");
			username = "Jeff";
			password = "test";
			instance = request.ESAPI.authenticator();
			result1 = instance.hashPassword(password, username);
			result2 = instance.hashPassword(password, username);
			assertTrue(result1.equals(result2));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testLogin" output="false"
	            hint="Test of login method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var username = "";
			var password = "";
			var user = "";
			var httpRequest = "";
			var httpResponse = "";
			var test = "";

			System.out.println("login");
			instance = request.ESAPI.authenticator();
			username = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			password = instance.generateStrongPassword();
			user = instance.createUser(username, password, password);
			user.enable();
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpRequest.addParameter("username", username);
			httpRequest.addParameter("password", password);
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			test = instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());
			assertTrue(test.isLoggedIn());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testRemoveUser" output="false"
	            hint="Test of removeAccount method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var accountName = "";
			var instance = "";
			var password = "";
			System.out.println("removeUser");
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			instance = request.ESAPI.authenticator();
			password = instance.generateStrongPassword();
			instance.createUser(accountName, password, password);
			assertTrue(instance.exists(accountName));
			instance.removeUser(accountName);
			assertFalse(instance.exists(accountName));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSaveUsers" output="false"
	            hint="Test of saveUsers method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var accountName = "";
			var instance = "";
			var password = "";

			System.out.println("saveUsers");
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			instance = request.ESAPI.authenticator();
			password = instance.generateStrongPassword();
			instance.createUser(accountName, password, password);
			instance.saveUsers();
			assertTrue(isObject(instance.getUserByAccountName(accountName)));
			instance.removeUser(accountName);
			assertFalse(isObject(instance.getUserByAccountName(accountName)));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetCurrentUser" output="false"
	            hint="Test of setCurrentUser method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var user1 = "";
			var user2 = "";
			var user3 = "";
			var userOne = "";
			var httpRequest = "";
			var httpResponse = "";
			var currentUser = "";
			var userTwo = "";

			System.out.println("setCurrentUser");
			instance = request.ESAPI.authenticator();
			user1 = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_UPPERS);
			user2 = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_UPPERS);
			userOne = instance.createUser(user1, "getCurrentUser", "getCurrentUser");
			userOne.enable();
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();;
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			userOne.loginWithPassword("getCurrentUser");
			currentUser = instance.getCurrentUser();
			assertEquals(currentUser, userOne);
			userTwo = instance.createUser(user2, "getCurrentUser", "getCurrentUser");
			instance.setCurrentUser(userTwo);
			assertFalse(currentUser.getAccountName() == userTwo.getAccountName());

			/* TODO make this work
			Runnable echo = new Runnable() {
			    private int count = 1;
			    public void run() {
			        User u=null;
			        try {
			            String password = ESAPI.randomizer().getRandomString(8, DefaultEncoder.CHAR_ALPHANUMERICS);
			            u = instance.createUser("test" + count++, password, password);
			            instance.setCurrentUser(u);
			            ESAPI.getLogger("test").info( Logger.SECURITY, true, "Got current user" );
			            // ESAPI.authenticator().removeUser( u.getAccountName() );
			        } catch (org.owasp.esapi.errors.AuthenticationException e) {
			            e.printStackTrace();
			        }
			    }
			};
			for ( int i = 0; i<10; i++ ) {
			    new Thread( echo ).start();
			} */
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetCurrentUserWithRequest" output="false"
	            hint="Test of setCurrentUser method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var password = "";
			var accountName = "";
			var user = "";
			var httpRequest = "";
			var httpResponse = "";

			System.out.println("setCurrentUser(req,resp)");
			instance = request.ESAPI.authenticator();
			instance.logout();// in case anyone is logged in
			password = instance.generateStrongPassword();
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			user = instance.createUser(accountName, password, password);
			user.enable();
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpRequest.addParameter("username", accountName);
			httpRequest.addParameter("password", password);
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());
			assertEquals(user, instance.getCurrentUser());
			try {
				user.disable();
				instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());
			}
			catch(org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			try {
				user.enable();
				user.lock();
				instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());
			}
			catch(org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			try {
				user.unlock();
				user.setExpirationTime(newJava("java.util.Date").init());
				instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());
			}
			catch(org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected`
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testValidatePasswordStrength" output="false"
	            hint="Test of validatePasswordStrength method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var username= "";
			var user = "";

			System.out.println("validatePasswordStrength");
			instance = request.ESAPI.authenticator();

	        username = "FictionalEsapiUser";
			user = createObject("component", "org.owasp.esapi.reference.DefaultUser").init(request.ESAPI, username);

			// should fail
			try {
				instance.verifyPasswordStrength("password", "jeff", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				instance.verifyPasswordStrength("diff123bang", "same123string", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				instance.verifyPasswordStrength("password", "JEFF", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				instance.verifyPasswordStrength("password", "1234", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				instance.verifyPasswordStrength("password", "password", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				instance.verifyPasswordStrength("password", "-1", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				instance.verifyPasswordStrength("password", "password123", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}
			try {
				instance.verifyPasswordStrength("password", "test123", user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// success
			}

			// should pass
			instance.verifyPasswordStrength("password", "jeffJEFF12!", user);
			instance.verifyPasswordStrength("password", "super calif ragil istic", user);
			instance.verifyPasswordStrength("password", "TONYTONYTONYTONY", user);
			instance.verifyPasswordStrength("password", instance.generateStrongPassword(), user);

			try {
				instance.verifyPasswordStrength("password", uCase(user.getAccountName()), user);
				fail("");
			}
			catch(org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// expected
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testExists" output="false"
	            hint="Test of exists method, of class org.owasp.esapi.Authenticator.">

		<cfscript>
			// CF8 requires 'var' at the top
			var accountName = "";
			var instance = "";
			var password = "";

			System.out.println("exists");
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			instance = request.ESAPI.authenticator();
			password = instance.generateStrongPassword();
			instance.createUser(accountName, password, password);
			assertTrue(instance.exists(accountName));
			instance.removeUser(accountName);
			assertFalse(instance.exists(accountName));
		</cfscript>

	</cffunction>

	<!---

	    <cffunction access="public" returntype="void" name="testMain" output="false" hint="Test of main method, of class org.owasp.esapi.Authenticator.">
	    <cfscript>
	    System.out.println( "Authenticator Main" );
	    var instance = request.ESAPI.authenticator();
	    var accountName = request.ESAPI.randomizer().getRandomString( 8, newJava( "org.owasp.esapi.reference.DefaultEncoder" ).CHAR_ALPHANUMERICS );
	    var password = instance.generateStrongPassword();
	    var role = "test";
	    // test wrong parameters - missing role parameter
	    var badargs = [accountName, password];
	    FileBasedAuthenticator.main( badargs );
	    // load users since the new user was added in another instance
	    instance.loadUsersImmediately();
	    var u1 = instance.getUser( accountName );
	    assertNull( u1 );
	    // test good parameters
	    var args = [accountName, password, role];
	    FileBasedAuthenticator.main( args );
	    // load users since the new user was added in another instance
	    authenticator.loadUsersImmediately();
	    var u2 = instance.getUser( accountName );
	    assertNotNull( u2 );
	    assertTrue( u2.isInRole( role ) );
	    assertEquals( instance.hashPassword( password, accountName ), instance.getHashedPassword( u2 ) );
	    </cfscript>
	    </cffunction>

	    --->
</cfcomponent>
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

		variables.CLASS = getMetaData(this);
		variables.CLASS_NAME = listLast(variables.CLASS.name, ".");
	</cfscript>

	<cffunction access="public" returntype="void" name="testAddCSRFToken" output="false"
	            hint="Test of addCSRFToken method, of class org.owasp.esapi.HTTPUtilities.">

		<cfscript>
			// CF8 requires 'var' at the top
			var csrf1 = "";
			var csrf2 = "";

			var instance = request.ESAPI.authenticator();
			var username = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			var user = instance.createUser(username, "addCSRFToken", "addCSRFToken");
			instance.setCurrentUser(user);

			System.out.println("addCSRFToken");
			csrf1 = request.ESAPI.httpUtilities().addCSRFToken("/test1");
			System.out.println("CSRF1:" & csrf1);
			assertTrue(csrf1.indexOf("?") > -1);

			csrf2 = request.ESAPI.httpUtilities().addCSRFToken("/test1?one=two");
			System.out.println("CSRF2:" & csrf2);
			assertTrue(csrf2.indexOf("&") > -1);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testChangeSessionIdentifier" output="false"
	            hint="Test of sendRedirect method, of class org.owasp.esapi.HTTPUtilities.">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpRequest = "";
			var httpResponse = "";
			var httpSession = "";
			var id1 = "";
			var id2 = "";

			System.out.println("changeSessionIdentifier");
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			httpSession = httpRequest.getSession();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			httpSession.setAttribute("one", "one");
			httpSession.setAttribute("two", "two");
			httpSession.setAttribute("three", "three");
			id1 = httpSession.getId();
			httpSession = request.ESAPI.httpUtilities().changeSessionIdentifier(request.ESAPI.currentRequest());
			id2 = httpSession.getId();
			assertTrue(!id1.equals(id2));
			assertEquals("one", httpSession.getAttribute("one"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetFileUploads" output="false"
	            hint="Test of formatHttpRequestForLog method, of class org.owasp.esapi.HTTPUtilities.">

		<cfscript>
			// CF8 requires 'var' at the top
			var dir = "";
			var content = "";
			var httpRequest1 = "";
			var httpResponse = "";
			var httpRequest2 = "";
			var list = "";
			var i = "";
			var f = "";
			var httpRequest3 = "";

			System.out.println("getFileUploads");
			dir = "";

			dir = createObject("component", "esapi4cf.test.org.owasp.esapi.util.FileTestUtils").createTmpDirectory(prefix=variables.CLASS_NAME);
			content = '--ridiculous\r\nContent-Disposition: form-data; name="upload"; filename="testupload.txt"\r\nContent-Type: application/octet-stream\r\n\r\nThis is a test of the multipart broadcast system.\r\nThis is only a test.\r\nStop.\r\n\r\n--ridiculous\r\nContent-Disposition: form-data; name="submit"\r\n\r\nSubmit Query\r\n--ridiculous--\r\nEpilogue';

			httpRequest1 = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init("/test", content.getBytes());
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest1, httpResponse);
			try {
				request.ESAPI.httpUtilities().getSafeFileUploads(request.ESAPI.currentRequest(), dir, dir);
				fail();
			}
			catch(org.owsap.esapi.errors.ValidationException e) {
				// expected
			}

			httpRequest2 = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init("/test", content.getBytes());
			httpRequest2.setContentType("multipart/form-data; boundary=ridiculous");
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest2, httpResponse);
			try {
				list = request.ESAPI.httpUtilities().getSafeFileUploads(request.ESAPI.currentRequest(), dir, dir);
				i = list.iterator();
				while(i.hasNext()) {
					f = i.next();
					System.out.println("  " & f.getAbsolutePath());
				}
				assertTrue(list.size() > 0);
			}
			catch(org.owsap.esapi.errors.ValidationException e) {
				fail();
			}

			httpRequest3 = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init("/test", content.replaceAll("txt", "ridiculous").getBytes());
			httpRequest3.setContentType("multipart/form-data; boundary=ridiculous");
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest3, httpResponse);
			try {
				request.ESAPI.httpUtilities().getSafeFileUploads(request.ESAPI.currentRequest(), dir, dir);
				fail();
			}
			catch(org.owsap.esapi.errors.ValidationException e) {
				// expected
			}
			createObject("component", "esapi4cf.test.org.owasp.esapi.util.FileTestUtils").deleteRecursively(dir);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testIsValidHTTPRequest" output="false"
	            hint="Test of isValidHTTPRequest method, of class org.owasp.esapi.HTTPUtilities.">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpRequest = "";
			var list = "";

			System.out.println("isValidHTTPRequest");
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpRequest.addParameter("p1", "v1");
			httpRequest.addParameter("p2", "v3");
			httpRequest.addParameter("p3", "v2");
			httpRequest.addHeader("h1", "v1");
			httpRequest.addHeader("h2", "v1");
			httpRequest.addHeader("h3", "v1");
			list = newJava("java.util.ArrayList").init();
			list.add(newJava("javax.servlet.http.Cookie").init("c1", "v1"));
			list.add(newJava("javax.servlet.http.Cookie").init("c2", "v2"));
			list.add(newJava("javax.servlet.http.Cookie").init("c3", "v3"));
			httpRequest.setCookies(list);
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init());

			// should throw IntrusionException which will be caught in isValidHTTPRequest and return false
			httpRequest.setMethod("JEFF");
			//assertFalse( request.ESAPI.validator().isValidHTTPRequest() );
			httpRequest.setMethod("POST");
			//assertTrue( request.ESAPI.validator().isValidHTTPRequest() );
			httpRequest.setMethod("GET");
			//assertTrue( request.ESAPI.validator().isValidHTTPRequest() );
			httpRequest.addParameter("bad_name", "bad*value");
			httpRequest.addHeader("bad_name", "bad*value");
			list.add(newJava("javax.servlet.http.Cookie").init("bad_name", "bad*value"));

			// call the validator directly, since the safe request will shield this from failing
			assertFalse(request.ESAPI.validator().isValidHTTPRequest(httpRequest));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testKillAllCookies" output="false"
	            hint="Test of killAllCookies method, of class org.owasp.esapi.HTTPUtilities.">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpRequest = "";
			var httpResponse = "";
			var safeResponse = "";

			System.out.println("killAllCookies");
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			safeResponse = createObject("component", "org.owasp.esapi.filters.SafeResponse").init(request.ESAPI, httpResponse);
			assertTrue(httpResponse.getCookies().isEmpty());
			list = newJava("java.util.ArrayList").init();
			list.add(newJava("javax.servlet.http.Cookie").init("test1", "1"));
			list.add(newJava("javax.servlet.http.Cookie").init("test2", "2"));
			list.add(newJava("javax.servlet.http.Cookie").init("test3", "3"));
			httpRequest.setCookies(list);
			request.ESAPI.httpUtilities().killAllCookies(request.ESAPI.currentRequest(), safeResponse);
			// this tests getHeaders because we're using addHeader in our setCookie method
			assertTrue(httpResponse.getHeaderNames().size() == 3);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testKillCookie" output="false"
	            hint="Test of killCookie method, of class org.owasp.esapi.HTTPUtilities.">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpRequest = "";
			var httpResponse = "";
			var safeResponse = "";

			System.out.println("killCookie");
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			safeResponse = createObject("component", "org.owasp.esapi.filters.SafeResponse").init(request.ESAPI, httpResponse);
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			assertTrue(httpResponse.getCookies().isEmpty());
			list = newJava("java.util.ArrayList").init();
			list.add(newJava("javax.servlet.http.Cookie").init("test1", "1"));
			list.add(newJava("javax.servlet.http.Cookie").init("test2", "2"));
			list.add(newJava("javax.servlet.http.Cookie").init("test3", "3"));
			httpRequest.setCookies(list);
			request.ESAPI.httpUtilities().killCookie(request.ESAPI.currentRequest(), safeResponse, "test1");
			// this tests getHeaders because we're using addHeader in our setCookie method
			assertTrue(httpResponse.getHeaderNames().size() == 1);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSendSafeRedirect" output="false"
	            hint="Test of sendRedirect method, of class org.owasp.esapi.HTTPUtilities.">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpResponse = "";
			var safeResponse = "";

			System.out.println("sendSafeRedirect");
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			safeResponse = createObject("component", "org.owasp.esapi.filters.SafeResponse").init(request.ESAPI, httpResponse);
			try {
				safeResponse.sendRedirect("/test1/abcdefg");
				safeResponse.sendRedirect("/test2/1234567");
			}
			catch(java.io.IOException e) {
				fail("");
			}
			try {
				safeResponse.sendRedirect("http://www.aspectsecurity.com");
				fail("");
			}
			catch(java.io.IOException e) {
				// expected
			}
			try {
				safeResponse.sendRedirect("/ridiculous");
				fail("");
			}
			catch(java.io.IOException e) {
				// expected
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetCookie" output="false"
	            hint="Test of setCookie method, of class org.owasp.esapi.HTTPUtilities.">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpResponse = "";
			var safeResponse = "";

			System.out.println("setCookie");
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			safeResponse = createObject("component", "org.owasp.esapi.filters.SafeResponse").init(request.ESAPI, httpResponse);
			assertTrue(httpResponse.getCookies().isEmpty());

			safeResponse.addCookie(newJava("javax.servlet.http.Cookie").init("test1", "test1"));
			assertTrue(httpResponse.getHeaderNames().size() == 1);

			safeResponse.addCookie(newJava("javax.servlet.http.Cookie").init("test2", "test2"));
			assertTrue(httpResponse.getHeaderNames().size() == 2);

			// test illegal name
			safeResponse.addCookie(newJava("javax.servlet.http.Cookie").init("tes<t3", "test3"));
			assertTrue(httpResponse.getHeaderNames().size() == 2);

			// test illegal value
			safeResponse.addCookie(newJava("javax.servlet.http.Cookie").init("test3", "tes<t3"));
			assertTrue(httpResponse.getHeaderNames().size() == 2);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetStateFromEncryptedCookie" output="false"
	            hint="">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpRequest = "";
			var httpResponse = "";
			var safeResponse = "";
			var map = "";
			var value = "";
			var encrypted = "";
			var state = "";
			var i = "";
			var entry = "";
			var origname = "";
			var origvalue = "";
			var test = "";

			System.out.println("getStateFromEncryptedCookie");
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			safeResponse = createObject("component", "org.owasp.esapi.filters.SafeResponse").init(request.ESAPI, httpResponse);
			map = {};
			map.put("one", "aspect");
			map.put("two", "ridiculous");
			map.put("test_hard", "&(@##*!^|;,.");
			try {
				request.ESAPI.httpUtilities().encryptStateInCookie(safeResponse, map);
				value = httpResponse.getHeader("Set-Cookie");
				encrypted = value.substring(value.indexOf("=") + 1, value.indexOf(";"));
				httpRequest.setCookie("state", encrypted);
				state = request.ESAPI.httpUtilities().decryptStateFromCookie(request.ESAPI.currentRequest());
				i = map.entrySet().iterator();
				while(i.hasNext()) {
					entry = i.next();
					origname = entry.getKey();
					origvalue = entry.getValue();
					test = "";
					if(structKeyExists(state, origname)) {
						test = state.get(origname);
					}
					if(test != origvalue) {
						fail("");
					}
				}
			}
			catch(org.owasp.esapi.errors.EncryptionException e) {
				fail("");
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSaveStateInEncryptedCookie" output="false"
	            hint="">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpRequest = "";
			var httpResponse = "";
			var safeResponse = "";
			var map = "";
			var value = "";
			var encrypted = "";

			System.out.println("saveStateInEncryptedCookie");
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			safeResponse = createObject("component", "org.owasp.esapi.filters.SafeResponse").init(request.ESAPI, httpResponse);
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			map = {};
			map.put("one", "aspect");
			map.put("two", "ridiculous");
			map.put("test_hard", "&(@##*!^|;,.");
			try {
				request.ESAPI.httpUtilities().encryptStateInCookie(safeResponse, map);
				value = httpResponse.getHeader("Set-Cookie");
				encrypted = value.substring(value.indexOf("=") + 1, value.indexOf(";"));
				request.ESAPI.encryptor().decryptString(encrypted);
			}
			catch(org.owasp.esapi.errors.EncryptionException e) {
				fail();
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetNoCacheHeaders" output="false"
	            hint="Test set no cache headers.">

		<cfscript>
			// CF8 requires 'var' at the top
			var httpRequest = "";
			var httpResponse = "";

			System.out.println("setNoCacheHeaders");
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			assertTrue(httpResponse.getHeaderNames().isEmpty());
			httpResponse.addHeader("test1", "1");
			httpResponse.addHeader("test2", "2");
			httpResponse.addHeader("test3", "3");
			assertFalse(httpResponse.getHeaderNames().isEmpty());
			request.ESAPI.httpUtilities().setNoCacheHeaders(request.ESAPI.currentResponse());
			assertTrue(httpResponse.containsHeader("Cache-Control"));
			assertTrue(httpResponse.containsHeader("Expires"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetRememberToken" output="false">

		<cfscript>
			// CF8 requires 'var' at the top
			var instance = "";
			var accountName = "";
			var password = "";
			var user = "";
			var httpRequest = "";
			var httpResponse = "";
			var maxAge = "";

			System.out.println("setRememberToken");
			instance = request.ESAPI.authenticator();
			accountName = request.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			password = instance.generateStrongPassword();
			user = instance.createUser(accountName, password, password);
			user.enable();
			httpRequest = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletRequest").init();
			httpRequest.addParameter("username", accountName);
			httpRequest.addParameter("password", password);
			httpResponse = createObject("component", "esapi4cf.test.org.owasp.esapi.http.TestHttpServletResponse").init();
			request.ESAPI.httpUtilities().setCurrentHTTP(httpRequest, httpResponse);
			instance.login(request.ESAPI.currentRequest(), request.ESAPI.currentResponse());

			maxAge = (60 * 60 * 24 * 14);
			request.ESAPI.httpUtilities().setRememberToken(request.ESAPI.currentRequest(), request.ESAPI.currentResponse(), password, maxAge, "domain", "/");
			// Can't test this because we're using safeSetCookie, which sets a header, not a real cookie!
			// String value = httpResponse.getCookie( Authenticator.REMEMBER_TOKEN_COOKIE_NAME ).getValue();
			// assertEquals( user.getRememberToken(), value );
		</cfscript>

	</cffunction>

</cfcomponent>
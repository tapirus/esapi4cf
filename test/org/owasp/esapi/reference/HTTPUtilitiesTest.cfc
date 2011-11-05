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
/**
 * The Class HTTPUtilitiesTest.
 */
component IntrusionDetectorTest extends="cfesapi.test.org.owasp.esapi.lang.TestCase" {

	instance.ESAPI = new cfesapi.org.owasp.esapi.ESAPI();

	instance.CLASS = getMetaData(this);
	instance.CLASS_NAME = listLast(instance.CLASS.name, ".");

	/**
	 * {@inheritDoc}
	 * @throws Exception
	 */
	
	public void function setUp() {
		structClear(request);
		structClear(session);
	}
	
	/**
	 * {@inheritDoc}
	 * @throws Exception
	 */
	
	public void function tearDown() {
		structClear(request);
		structClear(session);
	}
	
	public void function testCSRFToken() {
		newJava("java.lang.System").out.println("CSRFToken");
		local.username = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.Encoder").CHAR_ALPHANUMERICS);
		local.user = instance.ESAPI.authenticator().createUser(local.username, "addCSRFToken", "addCSRFToken");
		instance.ESAPI.authenticator().setCurrentUser(user=local.user);
		local.token = instance.ESAPI.httpUtilities().getCSRFToken();
		assertEquals(8, len(local.token));
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		try {
			instance.ESAPI.httpUtilities().verifyCSRFToken(local.request);
			fail();
		}
		catch(cfesapi.org.owasp.esapi.errors.IntrusionException e) {
			// expected
		}
		local.request.addParameter(instance.ESAPI.httpUtilities().CSRF_TOKEN_NAME, local.token);
		instance.ESAPI.httpUtilities().verifyCSRFToken(local.request);
	}
	
	/**
	 * Test of addCSRFToken method, of class org.owasp.esapi.HTTPUtilities.
	 * @throws AuthenticationException 
	 */
	
	public void function testAddCSRFToken() {
		local.authenticator = instance.ESAPI.authenticator();
		local.username = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
		local.user = local.authenticator.createUser(local.username, "addCSRFToken", "addCSRFToken");
		local.authenticator.setCurrentUser(user=local.user);
	
		newJava("java.lang.System").out.println("addCSRFToken");
		local.csrf1 = instance.ESAPI.httpUtilities().addCSRFToken("/test1");
		newJava("java.lang.System").out.println("CSRF1:" & local.csrf1);
		assertTrue(local.csrf1.indexOf("?") > -1);
	
		local.csrf2 = instance.ESAPI.httpUtilities().addCSRFToken("/test1?one=two");
		newJava("java.lang.System").out.println("CSRF2:" & local.csrf2);
		assertTrue(local.csrf2.indexOf("&") > -1);
	}
	
	/**
	 * Test of assertSecureRequest method, of class org.owasp.esapi.HTTPUtilities.
	 */
	
	public void function testAssertSecureRequest() {
		newJava("java.lang.System").out.println("assertSecureRequest");
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest().init();
		try {
			local.request.setRequestURL("http://example.com");
			instance.ESAPI.httpUtilities().assertSecureRequest(local.request);
			fail("");
		}
		catch(cfesapi.org.owasp.esapi.errors.AccessControlException e) {
			// pass
		}
		try {
			local.request.setRequestURL("ftp://example.com");
			instance.ESAPI.httpUtilities().assertSecureRequest(local.request);
			fail("");
		}
		catch(cfesapi.org.owasp.esapi.errors.AccessControlException e) {
			// pass
		}
		try {
			local.request.setRequestURL("");
			instance.ESAPI.httpUtilities().assertSecureRequest(local.request);
			fail("");
		}
		catch(cfesapi.org.owasp.esapi.errors.AccessControlException e) {
			// pass
		}
		/* NULL test
		try {
		    local.request.setRequestURL( null );
		    instance.ESAPI.httpUtilities().assertSecureRequest( local.request );
		    fail("");
		} catch( cfesapi.org.owasp.esapi.errors.AccessControlException e ) {
		    // pass
		}*/
		try {
			local.request.setRequestURL("https://example.com");
			instance.ESAPI.httpUtilities().assertSecureRequest(local.request);
			// pass
		}
		catch(cfesapi.org.owasp.esapi.errors.AccessControlException e) {
			fail("");
		}
	}
	
	/**
	 * Test of sendRedirect method, of class org.owasp.esapi.HTTPUtilities.
	 * 
	 * @throws EnterpriseSecurityException
	 */
	
	public void function testChangeSessionIdentifier() {
		newJava("java.lang.System").out.println("changeSessionIdentifier");
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		local.session = local.request.getSession();
		instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
		local.session.setAttribute("one", "one");
		local.session.setAttribute("two", "two");
		local.session.setAttribute("three", "three");
		local.id1 = local.session.getId();
		local.session = instance.ESAPI.httpUtilities().changeSessionIdentifier(local.request);
		local.id2 = local.session.getId();
		assertTrue(!local.id1.equals(local.id2));
		assertEquals("one", local.session.getAttribute("one"));
	}
	
	/**
	 * Test of formatHttpRequestForLog method, of class org.owasp.esapi.HTTPUtilities.
	 * @throws IOException 
	 */
	
	public void function testGetFileUploads() {
		local.home = "";
	
		try {
			local.home = new cfesapi.test.org.owasp.esapi.util.FileTestUtils().createTmpDirectory(prefix=instance.CLASS_NAME);
			local.content = '--ridiculous\r\nContent-Disposition: form-data; name="upload"; filename="testupload.txt"\r\nContent-Type: application/octet-stream\r\n\r\nThis is a test of the multipart broadcast system.\r\nThis is only a test.\r\nStop.\r\n\r\n--ridiculous\r\nContent-Disposition: form-data; name="submit"\r\n\r\nSubmit Query\r\n--ridiculous--\r\nEpilogue';
		
			local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
			local.request1 = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest(uri="/test", body=local.content.getBytes(local.response.getCharacterEncoding()));
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request1, local.response);
			try {
				instance.ESAPI.httpUtilities().getFileUploads(local.request1, local.home);
				fail();
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationUploadException e) {
				// expected
			}
			
			local.request2 = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest(uri="/test", body=local.content.getBytes(local.response.getCharacterEncoding()));
			local.request2.setContentType("multipart/form-data; boundary=ridiculous");
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request2, local.response);
			try {
				local.list = instance.ESAPI.httpUtilities().getFileUploads(local.request2, local.home);
				local.i = local.list.iterator();
				while(local.i.hasNext()) {
					local.f = local.i.next();
					newJava("java.lang.System").out.println("  " & local.f.getAbsolutePath());
				}
				assertTrue(local.list.size() > 0);
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationException e) {
				fail();
			}
			
			local.request4 = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest(uri="/test", body=local.content.getBytes(local.response.getCharacterEncoding()));
			local.request4.setContentType("multipart/form-data; boundary=ridiculous");
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request4, local.response);
			newJava("java.lang.System").err.println("UPLOAD DIRECTORY: " & instance.ESAPI.securityConfiguration().getUploadDirectory());
			try {
				local.list = instance.ESAPI.httpUtilities().getFileUploads(local.request4, local.home);
				local.i = local.list.iterator();
				while(local.i.hasNext()) {
					local.f = local.i.next();
					newJava("java.lang.System").out.println("  " & local.f.getAbsolutePath());
				}
				assertTrue(local.list.size() > 0);
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationException e) {
				newJava("java.lang.System").err.println("ERROR: " & e.toString());
				fail();
			}
			
			local.request3 = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest(uri="/test", body=local.content.replaceAll("txt", "ridiculous").getBytes(local.response.getCharacterEncoding()));
			local.request3.setContentType("multipart/form-data; boundary=ridiculous");
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request3, local.response);
			try {
				instance.ESAPI.httpUtilities().getFileUploads(local.request3, local.home);
				fail();
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationException e) {
				// expected
			}
		}
		finally
		{
			new cfesapi.test.org.owasp.esapi.util.FileTestUtils().deleteRecursively(local.home);
		}
	}
	
	/**
	 * Test of killAllCookies method, of class org.owasp.esapi.HTTPUtilities.
	 */
	
	public void function testKillAllCookies() {
		newJava("java.lang.System").out.println("killAllCookies");
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		assertTrue(local.response.getCookies().isEmpty());
		local.list = [];
		local.list.add(newJava("javax.servlet.http.Cookie").init("test1", "1"));
		local.list.add(newJava("javax.servlet.http.Cookie").init("test2", "2"));
		local.list.add(newJava("javax.servlet.http.Cookie").init("test3", "3"));
		local.request.setCookies(local.list);
		instance.ESAPI.httpUtilities().killAllCookies(local.request, local.response);
		assertTrue(local.response.getCookies().size() == 3);
	}
	
	/**
	 * Test of killCookie method, of class org.owasp.esapi.HTTPUtilities.
	 */
	
	public void function testKillCookie() {
		newJava("java.lang.System").out.println("killCookie");
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
		assertTrue(local.response.getCookies().isEmpty());
		local.list = [];
		local.list.add(newJava("javax.servlet.http.Cookie").init("test1", "1"));
		local.list.add(newJava("javax.servlet.http.Cookie").init("test2", "2"));
		local.list.add(newJava("javax.servlet.http.Cookie").init("test3", "3"));
		local.request.setCookies(local.list);
		instance.ESAPI.httpUtilities().killCookie(local.request, local.response, "test1");
		assertTrue(local.response.getCookies().size() == 1);
	}
	
	/**
	 * Test of sendRedirect method, of class org.owasp.esapi.HTTPUtilities.
	 * 
	 * @throws ValidationException the validation exception
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	
	public void function testSendSafeRedirect() {
		newJava("java.lang.System").out.println("sendSafeRedirect");
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		try {
			instance.ESAPI.httpUtilities().sendRedirect(local.response, "/test1/abcdefg");
			instance.ESAPI.httpUtilities().sendRedirect(local.response, "/test2/1234567");
		}
		catch(java.io.IOException e) {
			fail();
		}
		try {
			instance.ESAPI.httpUtilities().sendRedirect(local.response, "http://www.aspectsecurity.com");
			fail();
		}
		catch(java.io.IOException e) {
			// expected
		}
		try {
			instance.ESAPI.httpUtilities().sendRedirect(local.response, "/ridiculous");
			fail();
		}
		catch(java.io.IOException e) {
			// expected
		}
	}
	
	/**
	 * Test of setCookie method, of class org.owasp.esapi.HTTPUtilities.
	 */
	
	public void function testSetCookie() {
		newJava("java.lang.System").out.println("setCookie");
		local.httpUtilities = instance.ESAPI.httpUtilities();
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		assertTrue(local.response.getHeaderNames().isEmpty());
	
		local.httpUtilities.addCookie(local.response, newJava("javax.servlet.http.Cookie").init("test1", "test1"));
		assertTrue(local.response.getHeaderNames().size() == 1);
	
		local.httpUtilities.addCookie(local.response, newJava("javax.servlet.http.Cookie").init("test2", "test2"));
		assertTrue(local.response.getHeaderNames().size() == 2);
	
		// test illegal name
		local.httpUtilities.addCookie(local.response, newJava("javax.servlet.http.Cookie").init("tes<t3", "test3"));
		assertTrue(local.response.getHeaderNames().size() == 2);
	
		// test illegal value
		local.httpUtilities.addCookie(local.response, newJava("javax.servlet.http.Cookie").init("test3", "tes<t3"));
		assertTrue(local.response.getHeaderNames().size() == 2);
	}
	
	/**
	 *
	 * @throws java.lang.Exception
	 */
	
	public void function testGetStateFromEncryptedCookie() {
		newJava("java.lang.System").out.println("getStateFromEncryptedCookie");
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
	
		// test null cookie array
		local.empty = instance.ESAPI.httpUtilities().decryptStateFromCookie(local.request);
		assertTrue(local.empty.isEmpty());
	
		local.map = {};
		local.map.put("one", "aspect");
		local.map.put("two", "ridiculous");
		local.map.put("test_hard", "&(@##*!^|;,.");
		try {
			instance.ESAPI.httpUtilities().encryptStateInCookie(local.response, local.map);
			local.value = local.response.getHeader("Set-Cookie");
			local.encrypted = local.value.substring(local.value.indexOf("=") + 1, local.value.indexOf(";"));
			local.request.setCookie(instance.ESAPI.httpUtilities().ESAPI_STATE, local.encrypted);
			local.state = instance.ESAPI.httpUtilities().decryptStateFromCookie(local.request);
			local.i = local.map.entrySet().iterator();
			while(local.i.hasNext()) {
				local.entry = local.i.next();
				local.origname = local.entry.getKey();
				local.origvalue = local.entry.getValue();
				if(!local.state.get(local.origname) == local.origvalue) {
					fail();
				}
			}
		}
		catch(cfesapi.org.owasp.esapi.errors.EncryptionException e) {
			fail();
		}
	}
	
	/**
	 *
	 */
	
	public void function testSaveStateInEncryptedCookie() {
		newJava("java.lang.System").out.println("saveStateInEncryptedCookie");
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
		local.map = {};
		local.map.put("one", "aspect");
		local.map.put("two", "ridiculous");
		local.map.put("test_hard", "&(@##*!^|;,.");
		try {
			instance.ESAPI.httpUtilities().encryptStateInCookie(local.response, local.map);
			local.value = local.response.getHeader("Set-Cookie");
			local.encrypted = local.value.substring(local.value.indexOf("=") + 1, local.value.indexOf(";"));
			local.serializedCiphertext = newJava("org.owasp.esapi.codecs.Hex").decode(local.encrypted);
			local.restoredCipherText = new cfesapi.org.owasp.esapi.crypto.CipherText(instance.ESAPI).fromPortableSerializedBytes(local.serializedCiphertext);
			instance.ESAPI.encryptor().decrypt(ciphertext=local.restoredCipherText);
		}
		catch(cfesapi.org.owasp.esapi.errors.EncryptionException e) {
			fail();
		}
	}
	
	/**
	 *
	 */
	
	public void function testSaveTooLongStateInEncryptedCookieException() {
		newJava("java.lang.System").out.println("saveTooLongStateInEncryptedCookie");
	
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
	
		local.foo = instance.ESAPI.randomizer().getRandomString(4096, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
	
		local.map = {};
		local.map.put("long", local.foo);
		try {
			instance.ESAPI.httpUtilities().encryptStateInCookie(local.response, local.map);
			fail("Should have thrown an exception");
		}
		catch(cfesapi.org.owasp.esapi.errors.EncryptionException expected) {
			//expected
		}
	}
	
	/**
	 * Test set no cache headers.
	 */
	
	public void function testSetNoCacheHeaders() {
		newJava("java.lang.System").out.println("setNoCacheHeaders");
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
		assertTrue(local.response.getHeaderNames().isEmpty());
		local.response.addHeader("test1", "1");
		local.response.addHeader("test2", "2");
		local.response.addHeader("test3", "3");
		assertFalse(local.response.getHeaderNames().isEmpty());
		instance.ESAPI.httpUtilities().setNoCacheHeaders(local.response);
		assertTrue(local.response.containsHeader("Cache-Control"));
		assertTrue(local.response.containsHeader("Expires"));
	}
	
	/**
	 *
	 * @throws org.owasp.esapi.errors.AuthenticationException
	 */
	
	public void function testSetRememberToken() {
		newJava("java.lang.System").out.println("setRememberToken");
		local.authenticator = instance.ESAPI.authenticator();
		local.accountName = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
		local.password = local.authenticator.generateStrongPassword();
		local.user = local.authenticator.createUser(local.accountName, local.password, local.password);
		local.user.enable();
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.request.addParameter("username", local.accountName);
		local.request.addParameter("password", local.password);
		local.response = new cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse();
		local.authenticator.login(local.request, local.response);
	
		local.maxAge = (60 * 60 * 24 * 14);
		instance.ESAPI.httpUtilities().setRememberToken(local.request, local.response, local.password, local.maxAge, "domain", "/");
		// Can't test this because we're using safeSetCookie, which sets a header, not a real cookie!
		// String value = response.getCookie( Authenticator.REMEMBER_TOKEN_COOKIE_NAME ).getValue();
		// assertEquals( local.user.getRememberToken(), value );
	}
	
	public void function testGetSessionAttribute() {
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.session = local.request.getSession();
		local.session.setAttribute("testAttribute", newJava("java.lang.Float").init(43).floatValue());
	
		/* not sure how to make this test work as we do not cast in CF
		try {
		    local.test1 = instance.ESAPI.httpUtilities().getSessionAttribute( local.session, "testAttribute" );
		    fail("");
		} catch ( java.lang.ClassCastException cce ) {} */
		local.test2 = instance.ESAPI.httpUtilities().getSessionAttribute(local.session, "testAttribute");
		assertEquals(local.test2, newJava("java.lang.Float").init(43).floatValue());
	}
	
	public void function testGetRequestAttribute() {
		local.request = new cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest();
		local.request.setAttribute("testAttribute", newJava("java.lang.Float").init(43).floatValue());
	
		/* FIXME: not sure how to make this test work as we do not cast in CF
		try {
		    local.test1 = instance.ESAPI.httpUtilities().getRequestAttribute( local.request, "testAttribute" );
		    fail("");
		} catch ( java.lang.ClassCastException cce ) {} */
		local.test2 = instance.ESAPI.httpUtilities().getRequestAttribute(local.request, "testAttribute");
		assertEquals(local.test2, newJava("java.lang.Float").init(43).floatValue());
	}
	
}
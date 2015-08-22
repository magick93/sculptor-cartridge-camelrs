package org.sculptor.generator.cartridge.camelrs

import com.google.common.base.Supplier
import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import sculptormetamodel.Application
import org.sculptor.generator.util.OutputSlot

class ExampleWebXmlTmpl {
	
	@Inject extension Helper helper;
	@Inject extension WebXmlHelper webXmlHelper

	def webXml(Application it) {
		fileOutput("web_example.xml", OutputSlot::TO_GEN_RESOURCES, '''
		<?xml version="1.0" encoding="UTF-8"?>
		<web-app>
			«camelHttpServlet»
			«camelSwaggerServlet»
		</web-app>
	''')
	}
	
	def camelHttpServlet(Application it) '''
		«servlet(
			"CamelServlet",
			"Camel Http Transport Servlet",
			"org.apache.camel.component.servlet.CamelHttpTransportServlet", 1)»
		
		«servletMapping(
			"CamelServlet",
			"/" + restPath + "/*")»
	'''
	
	def camelSwaggerServlet(Application it) '''
		«servlet(
			"ApiDeclarationServlet",
			"Camel Swagger API Servlet",
			"org.apache.camel.component.swagger.DefaultCamelSwaggerServlet", 1, ['''
				«initParam("base.path"			, restPath)»
				«initParam("api.path"			, "api-docs")»
				«initParam("api.version"		, "1.0.0")»
				«initParam("api.title"			, "Documentation")»
				«initParam("api.description"	, "Documentation")»
			'''])»
		
		«servletMapping("ApiDeclarationServlet", "/api-docs/*")»
	'''
	
	def servletMapping(String name, String pattern) '''
		<servlet-mapping>
			<servlet-name>«name»</servlet-name>
			<url-pattern>«pattern»</url-pattern>
		</servlet-mapping>
	'''
	
	def servlet(String name, String displayName, String clazz, int load) {
		servlet(name, displayName, clazz, load, null)
	}
	
	def servlet(String name, String displayName, String clazz, int load, Supplier<String> initParams) '''
		<servlet>
			<display-name>«displayName»</display-name>
			<servlet-name>«name»</servlet-name>
			<servlet-class>«clazz»</servlet-class>
			<load-on-startup>«load»</load-on-startup>
			«IF initParams != null»
			«initParams.get»
			«ENDIF»
		</servlet>
	'''
	
	def initParam(String name, String value) '''
		<init-param>
			<param-name>«name»</param-name>
			<param-value>«value»</param-value>
		</init-param>
	'''
}
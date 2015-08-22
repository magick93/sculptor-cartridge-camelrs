package org.sculptor.generator.cartridge.camelrs

import javax.inject.Inject
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.PropertiesBase

class WebXmlHelper {
	
	@Inject extension Properties properties
	@Inject extension PropertiesBase propertiesBase
	
	def isWebXmlSampleToBeGenerated() {
		getBooleanProperty("generate.web.example", true)
	}
	
	def getRestPath() {
		getProperty("camelrs.restPath", "camel")
	}
	
	def getContextRoot() {
		getProperty("deployment.contextRoot", "context-path")
	}
	
	def getContextPath() {
		contextRoot + "/" + restPath
	}
	
	def getBooleanProperty(String name, boolean defaultValue) {
		if (!hasProperty(name)) {
			defaultValue
		} else {
			properties.getBooleanProperty(name)
		}
	}
}
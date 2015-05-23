package org.sculptor.generator.cartridge.camelrs

import sculptormetamodel.ResourceOperation
import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import sculptormetamodel.ServiceOperation
import org.sculptor.generator.util.HelperBase
import com.google.common.collect.ImmutableList
import org.sculptor.generator.ext.Properties

class JAXRSHelper {

	@Inject extension Helper helper
	@Inject extension HelperBase helperBase
	@Inject extension Properties properties

	def String getParentRelativePath(ResourceOperation it) {
		val relative = path.substring(resource
			.domainResourceName.toFirstLower.length + 1)
		return if(relative.empty) "/" else relative
	}

	public static val COLLECTIONS = 
		ImmutableList.builder
			.add("java.util.List")
			.add("java.util.Set")
			.build

	def String tryWrapGenericEntity(ServiceOperation it) {
		val type = typeName
		if(COLLECTIONS.exists[type.startsWith(it)])
			'''new javax.ws.rs.core.GenericEntity<«type»>(result){}'''
		else
			'''result'''
	}

	def boolean isSwaggerIntegrationEnabled() {
		getBooleanProperty("generate.swagger.annotation")
	}

	public def getMediaTypeProviders() {
		val providers = getProperty("jaxrs.providers", null)
		if (providers != null && providers.length > 0) {
			providers.split("[,; ]").map[trim].toList
		} else <String>newArrayList()
	}
}
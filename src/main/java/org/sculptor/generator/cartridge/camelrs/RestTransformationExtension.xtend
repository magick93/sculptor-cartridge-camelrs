package org.sculptor.generator.cartridge.camelrs

import org.sculptor.generator.transform.RestTransformation
import org.sculptor.generator.chain.ChainOverride
import sculptormetamodel.ResourceOperation
import org.sculptor.generator.ext.Helper
import javax.inject.Inject
import sculptormetamodel.HttpMethod

@ChainOverride
class RestTransformationExtension extends RestTransformation {

	@Inject extension Helper helper

	override addRestDefaults(ResourceOperation it) {
		val defaultReturn = defaultReturn
		if (returnString == null && defaultReturn != "")
			returnString = defaultReturn
		if (path == null)
			path = defaultPath
		if (httpMethod == null || httpMethod == HttpMethod::UNDEFINED)
			httpMethod = defaultHttpMethod.mapHttpMethod
		if (httpMethod == HttpMethod::PUT && name == "update" &&
				parameters.size == 1 && delegate?.name == "save" &&
					path == defaultPath) {
			addIdParameter
			path = path + "/{id}"
			addThrowsException
		}
		if ((throws == null || throws == "") && httpMethod == HttpMethod::DELETE)
			addThrowsException
		if (domainObjectType != null)
			domainObjectType.addXmlRootHint
		parameters.filter(e | e.domainObjectType != null).map[e |
			e.domainObjectType].forEach[addXmlRootHint]
	}
}
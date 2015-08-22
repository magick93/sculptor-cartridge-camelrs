package org.sculptor.generator.cartridge.camelrs

import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.template.RootTmpl
import sculptormetamodel.Application
import javax.inject.Inject

@ChainOverride
class RootTmplExtension extends RootTmpl {
	
	@Inject extension WebXmlHelper webXmlHelper
	
	@Inject ExampleWebXmlTmpl exampleWebXml
	
	override String root(Application it) '''
		«next.root(it)»
		«IF(webXmlSampleToBeGenerated)»
			«exampleWebXml.webXml(it)»
		«ENDIF»
	'''		
}
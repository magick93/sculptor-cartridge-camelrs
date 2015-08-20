package org.sculptor.generator.cartridge.camelrs

import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.template.spring.SpringTmpl
import sculptormetamodel.Application

@ChainOverride
class SpringTmplExtension extends SpringTmpl {
	
	override String spring(Application it) {}
	
}
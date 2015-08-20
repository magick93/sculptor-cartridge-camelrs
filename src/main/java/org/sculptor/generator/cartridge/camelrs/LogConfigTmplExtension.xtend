package org.sculptor.generator.cartridge.camelrs

import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.template.common.LogConfigTmpl
import sculptormetamodel.Application

@ChainOverride
class LogConfigTmplExtension extends LogConfigTmpl {
	
	override String logbackConfig(Application it) {}
	
}
package org.sculptor.generator.cartridge.camelrs

import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.template.jpa.JPATmpl
import sculptormetamodel.Application

@ChainOverride
class JPATmplExtension extends JPATmpl {
	
	override String persistenceUnitPropertiesTestHibernate(Application it, String unitName)
	'''
		<property name="hibernate.show_sql" value="true" />
		<property name="hibernate.hbm2ddl.auto" value="create-drop" />
		<property name="query.substitutions" value="true 1, false 0" />
		<property name="hibernate.cache.use_query_cache" value="true"/>
		<property name="hibernate.cache.use_second_level_cache" value="true"/>
	'''
	
}
package org.sculptor.generator.cartridge.camelrs

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.template.rest.RestWebTmpl
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import sculptormetamodel.Resource
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.PropertiesBase

@ChainOverride
class RestWebTmplExtension extends RestWebTmpl {
	
	@Inject extension Helper helper
	@Inject extension HelperBase helperBase
	@Inject extension Properties properties
	
	@Inject PropertiesBase propBase
	
	override restWeb(Application it) {
		writeRestApplicationfile
	}
	

	
	def String writeRestApplicationfile(Application it) {
		fileOutput(javaFileName(restPackage + ".RestApplication" ), OutputSlot::TO_GEN_SRC,
			'''
		«javaHeader»
		package «restPackage»;
		import javax.ws.rs.ApplicationPath;
		import javax.ws.rs.core.Application;
		import java.util.HashSet;
		import java.util.Set;
		
		/// Sculptor code formatter imports ///

		
		@ApplicationPath("/rest")
		public class RestApplication extends Application {
		    @Override
		    public Set<Class<?>> getClasses() {
		        final Set<Class<?>> classes = new HashSet<>();
		        «it.allResources.map[resourceBase].join»
		        return classes;
		    }
		}
		'''
		
		)
		
	}
	
		def String  resourceBase(Resource it) {
			'''
			classes.add(«name»Impl.class);
			'''
	}
	
	def restPackage(Application it) {
		concatPackage(basePackage, propBase.restPackage)
	}
	

	
}
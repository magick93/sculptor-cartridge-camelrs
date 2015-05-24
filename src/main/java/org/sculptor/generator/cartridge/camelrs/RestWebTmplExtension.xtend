package org.sculptor.generator.cartridge.camelrs

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.template.rest.RestWebTmpl
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import sculptormetamodel.Resource
import org.sculptor.generator.ext.Properties

@ChainOverride
class RestWebTmplExtension extends RestWebTmpl {
	
	@Inject extension Helper helper
	@Inject extension Properties properties
	
	override restWeb(Application it) {
		writeRestApplicationfile
	}
	

	
	def String writeRestApplicationfile(Application it) {
		
		//TODO - fix hardcoding of package
		fileOutput(javaFileName(basePackage+ ".trade.rest.RestApplication" ), OutputSlot::TO_GEN_SRC,
			'''
		«javaHeader»
		package «basePackage».trade.rest;
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
	

	
}
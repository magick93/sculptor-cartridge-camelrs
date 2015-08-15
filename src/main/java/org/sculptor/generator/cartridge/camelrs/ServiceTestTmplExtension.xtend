package org.sculptor.generator.cartridge.camelrs

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.service.ServiceTestTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Service

@ChainOverride	
class ServiceTestTmplExtension extends ServiceTestTmpl {
	
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties
	
	
	override String serviceJUnitSubclassWithAnnotations(Service it) {
		fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "Test"), OutputSlot::TO_SRC_TEST, '''
		«javaHeader()»
		package «it.getServiceapiPackage()»;
	
	/// Sculptor code formatter imports ///
	
		import static org.junit.Assert.*;
	
		/**
		 * CDI based transactional test with DbUnit support.
		 */
		public class «name»Test extends «databaseJpaTestCaseClass()» implements «name»TestBase {
	
			«serviceJUnitDependencyInjection(it)»
	
			«serviceJUnitGetDataSetFile(it)»
	
			«it.operations.filter(op | op.isPublicVisibility()).map(op| op.name).toSet().map[testMethod(it)].join()»
		}
		'''
		)
	}
	
	override String serviceJUnitDependencyInjection(Service it) {
	'''
		@javax.inject.Inject
		protected «it.getServiceapiPackage()».«name» «name.toFirstLower()»;
	'''
	}
	
	override String serviceDependencyInjectionJUnit(Service it) {
		fileOutput(javaFileName(it.getServiceimplPackage() + "." + name + "DependencyInjectionTest"), OutputSlot::TO_GEN_SRC_TEST, '''
		«javaHeader()»
		package «it.getServiceimplPackage()»;
		
		/// Sculptor code formatter imports ///
		
		/**
		 * JUnit test to verify that dependency injection setter methods
		 * of other CDI beans have been implemented.
		 */
		public class «name»DependencyInjectionTest extends junit.framework.TestCase {
		
			«it.otherDependencies.map[d | serviceDependencyInjectionTestMethod(d, it)].join()»
		
		}
		'''
		)
	}
}
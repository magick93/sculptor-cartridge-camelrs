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
		 * CDI based arquillian test with DbUnit support.
		 */
		@org.junit.runner.RunWith(org.jboss.arquillian.junit.Arquillian.class)
		public class «name»Test implements «name»TestBase {
			«arquillianDeployment(it)»
			«serviceJUnitDependencyInjection(it)»
	
			«serviceJUnitGetDataSetFile(it)»
	
			«it.operations.filter(op | op.isPublicVisibility()).map(op| op.name).toSet().map[testMethod(it)].join()»
		}
		'''
		)
	}
	
	def arquillianDeployment(Service it) '''
		@org.jboss.arquillian.container.test.api.Deployment
		public static WebArchive deploy() {
			java.io.File[] dependencies = org.jboss.shrinkwrap.resolver.api.maven.Maven.resolver()
			.loadPomFromFile("pom.xml")
			.importRuntimeDependencies()
			.resolve()
			.withTransitivity()
			.asFile();
			
			return org.jboss.shrinkwrap.api.ShrinkWrap.create(org.jboss.shrinkwrap.api.spec.WebArchive.class, "«name»Test.war")
				.addPackages(true, "«getBasePackage(it.module)»")
				.addAsLibraries(dependencies)
				.addAsResource("persistence-test.xml", "META-INF/persistence.xml")
				.addAsWebInfResource(org.jboss.shrinkwrap.api.asset.EmptyAsset.INSTANCE, "beans.xml");
		}
	'''
	
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
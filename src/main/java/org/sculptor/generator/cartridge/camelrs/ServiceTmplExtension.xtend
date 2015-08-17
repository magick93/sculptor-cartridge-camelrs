package org.sculptor.generator.cartridge.camelrs

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.template.common.PubSubTmpl
import org.sculptor.generator.template.service.ServiceTmpl
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Service
import sculptormetamodel.ServiceOperation
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.service.ServiceEjbTmpl

@ChainOverride
class ServiceTmplExtension extends ServiceTmpl {
	
	@Inject extension Helper helper
	@Inject extension HelperBase helperBase
	@Inject extension Properties properties
	
	@Inject ServiceEjbTmpl serviceEjbTmpl
	@Inject PubSubTmpl pubSubTmpl
	
	override String serviceImplSubclass(Service it) {
		fileOutput(javaFileName(it.getServiceimplPackage() + "." + name + "Impl"), OutputSlot::TO_SRC, '''
		«javaHeader()»
		package «it.getServiceimplPackage()»;
	
	/// Sculptor code formatter imports ///
	
		/**
		 * Implementation of «name».
		 */
		@javax.inject.Named("«name.toFirstLower()»")
		@javax.transaction.Transactional
		«IF webService»
			«serviceEjbTmpl.webServiceAnnotations(it)»
		«ENDIF»
		public class «name»Impl extends «name»ImplBase {
	
			public «name»Impl() {
			}
		«otherDependencies(it)»
	
			«it.operations.filter(op | op.isImplementedInGapClass()) .map[implMethod(it)].join()»
	
		}
		'''
		)
	}
	
	override String serviceImplBase(Service it) {
		fileOutput(javaFileName(it.getServiceimplPackage() + "." + name + "Impl" + (if (gapClass) "Base" else "")), OutputSlot::TO_GEN_SRC, '''
		«javaHeader()»
		package «it.getServiceimplPackage()»;
	
	/// Sculptor code formatter imports ///
	
		«IF gapClass»
			/**
			 * Generated base class for implementation of «name».
			«IF isSpringToBeGenerated()»
				 * <p>Make sure that subclass defines the following annotations:
				 * <pre>
				«springServiceAnnotation(it)»
				 * </pre>
				 *
			«ENDIF»
			 */
		«ELSE»
			/**
			 * Implementation of «name».
			 */
			«IF isSpringToBeGenerated()»
				«springServiceAnnotation(it)»
			«ENDIF»
			«IF !gapClass && webService»
				«serviceEjbTmpl.webServiceAnnotations(it)»
			«ENDIF»
		«ENDIF»
		«IF subscribe != null»«pubSubTmpl.subscribeAnnotation(it.subscribe)»«ENDIF»
		public «IF gapClass»abstract «ENDIF»class «name»Impl«IF gapClass»Base«ENDIF» «it.extendsLitteral()» implements «it.getServiceapiPackage()».«name» {
	
			public «name»Impl«IF gapClass»Base«ENDIF»() {
			}
	
			«delegateRepositories(it) »
			«delegateServices(it) »
	
			«it.operations.filter(op | !op.isImplementedInGapClass()).map[implMethod(it)].join»
	
			«serviceHook(it)»
		}
		'''
		)
	}
	
	override springServiceAnnotation(Service it) {
		'''
		@javax.inject.Named("«name.toFirstLower()»")
		@javax.transaction.Transactional
		'''
	}
	
	override String delegateRepositories(Service it) '''
		«FOR delegateRepository : it.getDelegateRepositories()»
			@javax.inject.Inject
			private «getRepositoryapiPackage(delegateRepository.aggregateRoot.module)».«delegateRepository.name» «delegateRepository.name.toFirstLower()»;
			
			protected «getRepositoryapiPackage(delegateRepository.aggregateRoot.module)».«delegateRepository.name» get«delegateRepository.name»() {
				return «delegateRepository.name.toFirstLower()»;
			}
		«ENDFOR»
	'''
	
	override String delegateServices(Service it) '''
		«FOR delegateService : it.getDelegateServices()»
			@javax.inject.Inject
			private «getServiceapiPackage(delegateService)».«delegateService.name» «delegateService.name.toFirstLower()»;
			
			protected «getServiceapiPackage(delegateService)».«delegateService.name» get«delegateService.name»() {
				return «delegateService.name.toFirstLower()»;
			}
		«ENDFOR»
	'''
	
	override String otherDependencies(Service it) '''
		«FOR dependency : otherDependencies»
			/**
			 * Dependency injection
			 */
			@javax.inject.Inject
			public void set«dependency.toFirstUpper()»(Object «dependency») {
				// TODO implement setter for dependency injection of «dependency»
				throw new UnsupportedOperationException("Implement setter for dependency injection of «dependency» in «name»Impl");
			}
			
		«ENDFOR»
	'''
	
	override String serviceMethodAnnotation(ServiceOperation it) '''
		«IF service.webService»
			@javax.jws.WebMethod
		«ENDIF»
		«IF publish != null»«pubSubTmpl.publishAnnotation(it.publish)»«ENDIF»
	'''
}
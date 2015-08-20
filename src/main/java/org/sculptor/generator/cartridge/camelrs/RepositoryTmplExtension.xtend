package org.sculptor.generator.cartridge.camelrs

import org.sculptor.generator.template.repository.RepositoryTmpl
import org.sculptor.generator.chain.ChainOverride
import sculptormetamodel.Repository
import javax.inject.Inject
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.template.common.PubSubTmpl

@ChainOverride
class RepositoryTmplExtension extends RepositoryTmpl {
	
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties
	
	@Inject PubSubTmpl pubSubTmpl
	
	override String repositoryBase(Repository it) {
		val baseName  = it.getRepositoryBaseName()
	
		fileOutput(javaFileName(aggregateRoot.module.getRepositoryimplPackage() + "." + name + (if (gapClass) "Base" else getSuffix("Impl"))), OutputSlot::TO_GEN_SRC, '''
		«javaHeader()»
		package «aggregateRoot.module.getRepositoryimplPackage()»;
	
	/// Sculptor code formatter imports ///
	
		«IF gapClass»
			/**
			 * Generated base class for implementation of Repository for «baseName»
			 * <p>Make sure that subclass defines the following annotations:
			 * <pre>
			     @javax.inject.Named("«name.toFirstLower()»")
			 * </pre>
			 *
			 */
		«ELSE»
			/**
			 * Repository implementation for «baseName»
			 */
			@javax.inject.Named("«name.toFirstLower()»")
		«ENDIF»
		«IF subscribe != null»«pubSubTmpl.subscribeAnnotation(it.subscribe)»«ENDIF»
		public «IF gapClass»abstract «ENDIF»class «name»«if (gapClass) "Base" else getSuffix("Impl")» «it.extendsLitteral()»
			implements «aggregateRoot.module.getRepositoryapiPackage()».«name» {
	
			public «name»«if (gapClass) "Base" else getSuffix("Impl")»() {
			}
	
			«fetchEagerFields»
			«repositoryDependencies(it)»
	
			«it.operations.filter(op | op.delegateToAccessObject && !op.isGenericAccessObject()).map[op | baseRepositoryMethod(op)].join()»
			«it.operations.filter(op | op.isGenericAccessObject()).filter(e|!e.hasPagingParameter()).map[op | genericBaseRepositoryMethod(op)].join()»
			«it.operations.filter(op | op.isGenericAccessObject() && op.hasPagingParameter()).map[op | pagedGenericBaseRepositoryMethod(op)].join()»
	
			«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && !op.isGeneratedFinder()).map[op | abstractBaseRepositoryMethod(op)].join()»
			«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && op.isGeneratedFinder()).map[op | finderMethod(op)].join()»
	
			«IF jpa()»
				«entityManagerDependency(it) »
			«ENDIF»
		
			«extraRepositoryBaseDependencies»
			
			«accessObjectFactory(it)»
		
			«repositoryHook(it)»
		
		}
		'''
		)
	}
	
	override String repositoryDependencies(Repository it) {
		'''
		«FOR dependency : repositoryDependencies»
			@javax.inject.Inject
			private «dependency.aggregateRoot.module.getRepositoryapiPackage()».«dependency.name» «dependency.name.toFirstLower()»;
			
			protected «dependency.aggregateRoot.module.getRepositoryapiPackage()».«dependency.name» get«dependency.name»() {
				return «dependency.name.toFirstLower()»;
			}
		«ENDFOR»
		'''
	}
	
	override String repositorySubclass(Repository it) {
		val baseName = it.getRepositoryBaseName()
	
		fileOutput(javaFileName(aggregateRoot.module.getRepositoryimplPackage() + "." + name + getSuffix("Impl")), OutputSlot::TO_SRC, '''
			«javaHeader()»
			package «aggregateRoot.module.getRepositoryimplPackage()»;
		
		/// Sculptor code formatter imports ///
		
			/**
			 * Repository implementation for «baseName»
			 */
			@javax.inject.Named("«name.toFirstLower()»")
			public class «name + getSuffix("Impl")» extends «name»Base {
		
				public «name + getSuffix("Impl")»() {
				}
		
				«otherDependencies(it)»
		
				«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && !op.isGeneratedFinder()).map[subclassRepositoryMethod(it)].join()»
		
			}
			'''
		)
	}
	
	override String otherDependencies(Repository it) {
		'''
		«FOR dependency : otherDependencies»
		/**
		 * Dependency injection
		 */
		@javax.inject.Inject
		public void set«dependency.toFirstUpper()»(Object «dependency») {
			// TODO implement setter for dependency injection of «dependency»
			throw new UnsupportedOperationException("Implement setter for dependency injection of «dependency» in «name + getSuffix("Impl")»");
		}
		«ENDFOR»
		'''
	}
}
package org.sculptor.generator.cartridge.camelrs

import com.google.common.collect.Iterables
import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.template.rest.ResourceTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.HttpMethod
import sculptormetamodel.NamedElement
import sculptormetamodel.Parameter
import sculptormetamodel.Resource
import sculptormetamodel.ResourceOperation
import sculptormetamodel.ServiceOperation
import com.google.common.primitives.Primitives
import sculptormetamodel.DomainObject

@ChainOverride
class ResourceTmplExtension extends ResourceTmpl {

	@Inject private var ExceptionTmpl exceptionTmpl

	@Inject extension Helper helper
	@Inject extension HelperBase helperBase
	@Inject extension Properties properties

	@Inject extension JAXRSHelper jaxrsHelper
	
	override String resourceBase(Resource it) {
		writeCamelRestDsl
	}
	
	override String resourceSubclass(Resource it) {
		fileOutput(javaFileName(it.getRestPackage() + "." + name), OutputSlot::TO_SRC, '''
		«javaHeader()»
		package «it.getRestPackage()»;
		
		/// Sculptor code formatter imports ///
		
		/**
		 * Implementation of «name».
		 */
		@javax.ejb.Startup
		@javax.enterprise.context.ApplicationScoped
		@org.apache.camel.cdi.ContextName("rest-camel-context")
		public class «name» extends «name»Impl {
		
			public «name»() {
			}
		
			«it.operations.filter(op | op.isImplementedInGapClass()) .map[resourceMethod(it)].join()»
		
		}
		'''
		)
	}
	

	//TODO - add JEE dependencies to pom
	//TODO - add Camel dependencies to pom
	//TODO - correct class/file name
	def String writeCamelRestDsl(Resource it) {
		it.module.name
		fileOutput(javaFileName(restPackage + "." + name + (if (gapClass) "Impl" else "RouteBuilder")), OutputSlot::TO_GEN_SRC,
			'''
		«javaHeader»
		package «restPackage»;
		import javax.inject.Inject; 
		import org.apache.camel.builder.RouteBuilder;
		«imports»
		«jaxrsMediaImports»
		
		/// Sculptor code formatter imports ///

		public class«IF gapClass»«ENDIF» «name»«IF gapClass»Impl«ENDIF»«it.extendsLitteral» extends RouteBuilder {
			
			«injectDelegateServices»
			
			@Override
			public void configure() throws Exception {
				restConfiguration()
					.contextPath("/«contextPath»")
					.port(8080)
					.component("servlet")
					.bindingMode(org.apache.camel.model.rest.RestBindingMode.json);
				
				rest("/«it.module.name»")
					«operations.filter[!implementedInGapClass].map[rsMethodType].join»«operations.filter[!implementedInGapClass].map[rsMethodTypeLast].last»
				
				«operations.filter[!implementedInGapClass].filter[delegate != null].map[camelBeanDelegation].join»
			}
		}
		'''
		)
	}
	
	def camelBeanDelegation(ResourceOperation it) '''
		from("«routeName»")
			«IF routeName == "direct:delete"»
			«resource.operations.findFirst[delegate.name == "findById"].beanDelegation»
			«ENDIF»
			«beanDelegation»;
	'''
	
	def beanDelegation(ResourceOperation it) 
		'''.bean(«delegate.service.name.toFirstLower», "«delegate.camelCall»")'''
	
	def camelCall(ServiceOperation it) 
		'''«name»(«parameters.map[camelParameter].join(", ")»)'''
	
	/*
	 * ServiceContext instances is set to null
	 * Primitive types (and wrappers) are substituted with call to ${header.name}
	 * Other parameter types are substituted with ${body}
	 */
	def camelParameter(Parameter it) {
		if (type == "org.sculptor.framework.context.ServiceContext") "null"
		else if (type.isPrimitive) '''${header.«name»}'''
		else "${body}"
	}
	
	def isPrimitive(String str) {
		Primitives::allPrimitiveTypes.exists[name == str || simpleName == str]
			|| Primitives::allWrapperTypes.exists[name == str || simpleName == str]
	}
	
	def routeName(ResourceOperation it) {
		"direct:" + name
	}
	
	def String rsMethodType(ResourceOperation it) {
		//TODO: causes a NPE
		//TODO: fix hardcode
		'''
		.«httpMethod.toString.toLowerCase»(«IF parentRelativePath != null»"«parentRelativePath»"«ENDIF»)
		  .produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
		  «IF parameters.exists[domainObjectType != null]»
		  .type(«parameters.findFirst[domainObjectType != null].domainObjectType.domainObjectClass».class)
		  «ENDIF»
		  .to("«routeName»")
		  
		  '''
	}
	
	def domainObjectClass(DomainObject it) {
		domainPackage + "." + name
	}
	
	def String rsMethodTypeLast(ResourceOperation it) {
		''';
		'''
	}

	def String injectDelegateServices(Resource it) {
		'''
		«FOR delegateService : it.getDelegateServices()»
			@Inject «getServiceapiPackage(delegateService)».«delegateService.name.toFirstUpper» «delegateService.name.toFirstLower()»;

			protected «getServiceapiPackage(delegateService)».«delegateService.name
				» get«delegateService.name»() {
				return «delegateService.name.toFirstLower()»;
			}
		«ENDFOR»
		'''
	}
	
	def String imports(Resource it){
		'''
		«FOR delegateService : it.getDelegateServices()»
			import «getServiceapiPackage(delegateService)».«delegateService.name.toFirstUpper»;
		«ENDFOR»
		'''
		
	}



	def String jaxrsClassAnnotation(Resource it) {
		'''
	
		@javax.ws.rs.Path("/«domainResourceName.toFirstLower»")
		«IF swaggerIntegrationEnabled»
			«swaggerApiAnnotation»
		«ENDIF»
		«jaxrsMediaTypes»
		'''
	}

	def String jaxrsMediaTypes(Resource it) {
		val types = mediaTypeProviders?.map["javax.ws.rs.core.MediaType." + it].join(", ")
		'''
			«IF types != null && !types.empty»
				@javax.ws.rs.Produces({«types»})
				@javax.ws.rs.Consumes({«types»})
			«ENDIF»
		'''
	}
	
	def String jaxrsMediaImports(Resource it) {
		val types = mediaTypeProviders?.map["javax.ws.rs.core.MediaType." + it].join(", ")
		'''
			«IF mediaTypeProviders != null && !mediaTypeProviders.empty»
				import javax.ws.rs.Produces.«types»;
				import javax.ws.rs.Consumes.«types»;
			«ENDIF»
		'''
	}

	def String jaxrsMethod(ResourceOperation it) {
		val javadoc = it.formatJavaDoc;
		'''
			«IF !javadoc.empty»
				«javadoc»
			«ELSEIF delegate != null »
				/**
				 * Delegates to {@link «getServiceapiPackage(delegate.service)».«delegate.service.name»#«delegate.name»}
				 */
			«ENDIF»
			«jaxrsMethodAnnotation»
			«jaxrsMethodSignature» 
			
			{
				«IF implementedInGapClass»
					«jaxrsMethodHandWritten»
				«ELSE»
					«IF delegate != null»
						«jaxrsMethodDelegation»
					«ENDIF»
					«jaxrsMethodReturn»
				«ENDIF»
			}
		'''
	}

	def String jaxrsMethodAnnotation(ResourceOperation it) {
		'''
		@javax.ws.rs.«httpMethod»
		@javax.ws.rs.Path("«parentRelativePath»")
		«IF swaggerIntegrationEnabled»
			«swaggerApiOperationAnnotation»
		«ENDIF»
		'''
	}
	


	def String jaxrsMethodHandWritten(ResourceOperation it) {
		'''
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
			«IF returnString != null»// return "«returnString»";«ENDIF»
		'''
	}

	def String jaxrsMethodDelegation(ResourceOperation it) {
		'''
		«jaxrsUpdateDelegate»
		«resourceMethodDelegation»
		'''
	}

	def String jaxrsUpdateDelegate(ResourceOperation it) {
		val idOperation = delegate.service.operations.filter(e |
			e.domainObjectType != null && e.collectionType == null &&
				e.parameters.size == 2 && e.parameters.last.type ==
					e.domainObjectType.idAttributeType).head;
		val domainObject = parameters.filter(e |
				e.domainObjectType != null).head?.domainObjectType
		'''
		«IF httpMethod == HttpMethod::PUT && path.contains("{id}") &&
			parameters.exists(e | e.name == "id") && domainObject != null»
			«IF idOperation == null»
			««« That's the only way to subdue "unreachable code" compiler error
				if (true) throw new Exception("can't delete due to no matching«
					» findById method in service");
			«ELSE»
				«delegate.typeName» newEntity = entity;
				entity = «idOperation.service.name.toFirstLower».«
					idOperation.name»(serviceContext(), id);
				«FOR a : Iterables.<NamedElement>concat(
					domainObject.attributes.filter[a |
						a.visibilityLitteralSetter.startsWith("public") && !a.uuid
							&& !a.auditableAttribute].map[a | a as NamedElement],
					domainObject.references.filter[a |
						a.visibilityLitteralSetter.startsWith("public")
							&& !a.collection].map[a | a as NamedElement])»

					if(newEntity.get«a.name.toFirstUpper»() != null)
						entity.set«a.name.toFirstUpper
							»(newEntity.get«a.name.toFirstUpper»());
				«ENDFOR»

			«ENDIF»
		«ENDIF»
		'''
	}

	def String jaxrsMethodReturn(ResourceOperation it) {
		'''
			«IF delegate != null && httpMethod == HttpMethod::DELETE && path
				.contains("{id}") && !parameters.exists(e | e.name == "id") &&
					parameters.exists(e | e.domainObjectType != null)»
				«IF delegate?.service.operations.filter(e|e.domainObjectType != null
					&& e.collectionType == null && e.parameters.exists(p | p.type ==
						e.domainObjectType.idAttributeType)).head == null»
					throw new Exception("can't delete due to no matching findById«
						» method in service");
				«ELSE»
					return Response.ok(deleteObj).build();
				«ENDIF»
			«ELSEIF delegate != null && delegate.typeName == "void"»
				return Response.ok().build();
			«ELSEIF delegate != null»
				return Response.ok(«delegate.domainObjectType»).build();
			«ELSEIF returnString != null»
				return Response.ok("«returnString»").build();
			«ELSE»
				return Response.status(javax.ws.rs.core.Response.Status.«
					»INTERNAL_SERVER_ERROR).build();
			«ENDIF»
		'''
	}

	def String jaxrsMethodSignature(ResourceOperation it) {
		'''
		«it.visibilityLitteral» javax.ws.rs.core.Response «name.toFirstUpper»(«it.parameters.map[p | p.jaxrsAnnotatedParam(it)].join(", ")») «
				exceptionTmpl.throwsDecl(it)»;
		'''
	}
	
	def String jaxrsAnnotatedParam(Parameter it, ResourceOperation op) {
		'''
			«IF op.httpMethod == HttpMethod::DELETE && domainObjectType != null &&
					domainObjectType.getIdAttribute() != null && op.path.contains("{id}")
				»@javax.ws.rs.PathParam("id") «domainObjectType.getIdAttributeType» id
			«ELSE»
				«IF op.path.contains("{" + name + "}")»
					@javax.ws.rs.PathParam("«name»") 
				«ENDIF»
				«getTypeName» «name»
			«ENDIF»
		'''
	}

	def String jaxrsAbstractMethod(ResourceOperation it) {
		'''
			«it.getVisibilityLitteral()» abstract javax.ws.rs.core.Response «
				name»(«it.parameters.map[paramTypeAndName(it)].join(",")») «
						exceptionTmpl.throwsDecl(it)»;
		'''
	}

	def String swaggerApiAnnotation(Resource it) {
		'''
			@com.wordnik.swagger.annotations.Api(value = "/«domainResourceName
				.toFirstLower»", description = "«name»")
		'''
	}

	def String swaggerApiOperationAnnotation(ResourceOperation it) {
		'''
			@com.wordnik.swagger.annotations.ApiOperation(value = "«name»"
			«IF delegate != null», notes = "Delegates to «delegate.service
				.serviceapiPackage».«delegate.service.name»#«delegate.name
					»"«swaggerApiOperationResponse»«ENDIF»)
		'''
	}

	def String swaggerApiOperationResponse(ResourceOperation it) {
		if (httpMethod == HttpMethod::DELETE && path.contains("{id}")
				&& !parameters.exists[e | e.name == "id"]) {
			val domainObjectName = parameters.filter[e | e.domainObjectType
				!= null].head?.domainObjectType.name
			if (domainObjectName != null)
				return ''', response = «domainObjectName».class'''
		}

		val type = delegate.typeName
		if (type == "void")
			return ""

		val collection = JAXRSHelper.COLLECTIONS.filter[type.startsWith(it)].head
		return ''', «IF collection != null»response = «type.substring(collection
			.length + 1, type.length - 1)».class, responseContainer = "«collection
				.substring(collection.lastIndexOf('.') + 1)»"«ELSE»response = «type
					».class«ENDIF»'''
	}
	
	def contextPath() {
		getProperty("deployment.context-path", "contetPath")
	}
}
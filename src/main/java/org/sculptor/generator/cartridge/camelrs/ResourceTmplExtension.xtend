package org.sculptor.generator.cartridge.camelrs

import org.sculptor.generator.template.rest.ResourceTmpl
import org.sculptor.generator.chain.ChainOverride
import sculptormetamodel.Resource
import javax.inject.Inject
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import sculptormetamodel.ResourceOperation
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Parameter
import sculptormetamodel.HttpMethod
import org.sculptor.generator.template.common.ExceptionTmpl
import sculptormetamodel.NamedElement
import com.google.common.collect.Iterables
import sculptormetamodel.DomainObjectTypedElement

@ChainOverride
class ResourceTmplExtension extends ResourceTmpl {

	@Inject private var ExceptionTmpl exceptionTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

	@Inject extension JAXRSHelper jaxrsHelper

	override String resourceBase(Resource it) {
		fileOutput(javaFileName(restPackage + "." + name + (if (gapClass) "Base" else "")), OutputSlot::TO_GEN_SRC,
		'''
		�javaHeader�
		package �restPackage�;

		/// Sculptor code formatter imports ///

		�IF gapClass�
			/**
			 * Generated base class for implementation of �name�.
			 * <p>Make sure that subclass defines the following annotations:
			 * <pre>
			�jaxrsClassAnnotation�
			 * </pre>
			 */
		�ELSE�
			/**
			 * Resource Implementation of �name�.
			 */
			�jaxrsClassAnnotation�
		�ENDIF�
		public �IF gapClass�abstract �ENDIF�class �name��IF gapClass�Base�ENDIF� �it.extendsLitteral� {

			public �name��IF gapClass�Base�ENDIF�() {
			}

			�IF serviceContextToBeGenerated�
				�serviceContext�
			�ENDIF�

			�injectDelegateServices�

			�operations.filter(op | !op.implementedInGapClass).map[jaxrsMethod].join�

			�operations.filter(op |  op.implementedInGapClass).map[jaxrsAbstractMethod].join�
		}
		'''
		)
	}

	def String injectDelegateServices(Resource it) {
		'''
		�FOR delegateService : it.getDelegateServices()�
			@javax.ejb.EJB
			private �getServiceapiPackage(delegateService)�.�delegateService.name
				��IF delegateService.localInterface�Local�ENDIF
					� �delegateService.name.toFirstLower()�;

			protected �getServiceapiPackage(delegateService)�.�delegateService.name
				� get�delegateService.name�() {
				return �delegateService.name.toFirstLower()�;
			}
		�ENDFOR�
		'''
	}

	override String resourceSubclass(Resource it) {
		fileOutput(javaFileName(restPackage + "." + name), OutputSlot::TO_SRC,
		'''
		�javaHeader�
		package �restPackage�;

		/// Sculptor code formatter imports ///

		/**
		 * Implementation of �name�.
		 */
		�jaxrsClassAnnotation�
		public class �name� extends �name�Base {

			public �name�() {
			}

			�operations.filter(op | op.implementedInGapClass).map[jaxrsMethod].join�

		}
		'''
		)

	}

	def String jaxrsClassAnnotation(Resource it) {
		'''
		@javax.ejb.Stateless
		@javax.ws.rs.Path("/�domainResourceName.toFirstLower�")
		�IF swaggerIntegrationEnabled�
			�swaggerApiAnnotation�
		�ENDIF�
		�jaxrsMediaTypes�
		'''
	}

	def String jaxrsMediaTypes() {
		val types = mediaTypeProviders?.map["javax.ws.rs.core.MediaType." + it].join(", ")
		'''
			�IF types != null && !types.empty�
				@javax.ws.rs.Produces({�types�})
				@javax.ws.rs.Consumes({�types�})
			�ENDIF�
		'''
	}

	def String jaxrsMethod(ResourceOperation it) {
		val javadoc = it.formatJavaDoc;
		'''
			�IF !javadoc.empty�
				�javadoc�
			�ELSEIF delegate != null �
				/**
				 * Delegates to {@link �getServiceapiPackage(delegate.service)�.�delegate.service.name�#�delegate.name�}
				 */
			�ENDIF�
			�jaxrsMethodAnnotation�
			�jaxrsMethodSignature� {
				�IF implementedInGapClass�
					�jaxrsMethodHandWritten�
				�ELSE�
					�IF delegate != null�
						�jaxrsMethodDelegation�
					�ENDIF�
					�jaxrsMethodReturn�
				�ENDIF�
			}
		'''
	}

	def String jaxrsMethodAnnotation(ResourceOperation it) {
		'''
		@javax.ws.rs.�httpMethod�
		@javax.ws.rs.Path("�parentRelativePath�")
		�IF swaggerIntegrationEnabled�
			�swaggerApiOperationAnnotation�
		�ENDIF�
		'''
	}

	def String jaxrsMethodHandWritten(ResourceOperation it) {
		'''
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("�name� not implemented");
			�IF returnString != null�// return "�returnString�";�ENDIF�
		'''
	}

	def String jaxrsMethodDelegation(ResourceOperation it) {
		'''
		�jaxrsUpdateDelegate�
		�resourceMethodDelegation�
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
		�IF httpMethod == HttpMethod::PUT && path.contains("{id}") &&
			parameters.exists(e | e.name == "id") && domainObject != null�
			�IF idOperation == null�
			��� That's the only way to subdue "unreachable code" compiler error
				if (true) throw new Exception("can't delete due to no matching�
					� findById method in service");
			�ELSE�
				�delegate.typeName� newEntity = entity;
				entity = �idOperation.service.name.toFirstLower�.�
					idOperation.name�(serviceContext(), id);
				�FOR a : Iterables.<DomainObjectTypedElement>concat(
					domainObject.attributes.filter[a |
						a.visibilityLitteralSetter.startsWith("public") && !a.uuid
							&& !a.auditableAttribute].map[a | a as DomainObjectTypedElement],
					domainObject.references.filter[a |
						a.visibilityLitteralSetter.startsWith("public")
							&& !a.collection].map[a | a as DomainObjectTypedElement])�

					if(newEntity.get�a.name.toFirstUpper�() != null)
						entity.set�a.name.toFirstUpper
							�(newEntity.get�a.name.toFirstUpper�());
				�ENDFOR�

			�ENDIF�
		�ENDIF�
		'''
	}

	def String jaxrsMethodReturn(ResourceOperation it) {
		'''
			�IF delegate != null && httpMethod == HttpMethod::DELETE && path
				.contains("{id}") && !parameters.exists(e | e.name == "id") &&
					parameters.exists(e | e.domainObjectType != null)�
				�IF delegate?.service.operations.filter(e|e.domainObjectType != null
					&& e.collectionType == null && e.parameters.exists(p | p.type ==
						e.domainObjectType.idAttributeType)).head == null�
					throw new Exception("can't delete due to no matching findById�
						� method in service");
				�ELSE�
					return Response.ok(deleteObj).build();
				�ENDIF�
			�ELSEIF delegate != null && delegate.typeName == "void"�
				return Response.ok().build();
			�ELSEIF delegate != null�
				return Response.ok(�delegate.tryWrapGenericEntity�).build();
			�ELSEIF returnString != null�
				return Response.ok("�returnString�").build();
			�ELSE�
				return Response.status(javax.ws.rs.core.Response.Status.�
					�INTERNAL_SERVER_ERROR).build();
			�ENDIF�
		'''
	}

	def String jaxrsMethodSignature(ResourceOperation it) {
		'''
		�it.visibilityLitteral� javax.ws.rs.core.Response �name�(�it.parameters
			.map[p | p.jaxrsAnnotatedParam(it)].join(", ")�) �
				exceptionTmpl.throwsDecl(it)�
		'''
	}
	
	def String jaxrsAnnotatedParam(Parameter it, ResourceOperation op) {
		'''
			�IF op.httpMethod == HttpMethod::DELETE && domainObjectType != null &&
					domainObjectType.getIdAttribute() != null && op.path.contains("{id}")
				�@javax.ws.rs.PathParam("id") �domainObjectType.getIdAttributeType� id
			�ELSE�
				�IF op.path.contains("{" + name + "}")�
					@javax.ws.rs.PathParam("�name�") 
				�ENDIF�
				�getTypeName� �name�
			�ENDIF�
		'''
	}

	def String jaxrsAbstractMethod(ResourceOperation it) {
		'''
			�it.getVisibilityLitteral()� abstract javax.ws.rs.core.Response 
				�name�(�it.parameters.map[paramTypeAndName(it)].join(",")�)		�exceptionTmpl.throwsDecl(it)�;
		'''
	}

	def String swaggerApiAnnotation(Resource it) {
		'''
			@com.wordnik.swagger.annotations.Api(value = "/�domainResourceName
				.toFirstLower�", description = "�name�")
		'''
	}

	def String swaggerApiOperationAnnotation(ResourceOperation it) {
		'''
			@com.wordnik.swagger.annotations.ApiOperation(value = "�name�"
			�IF delegate != null�, notes = "Delegates to �delegate.service
				.serviceapiPackage�.�delegate.service.name�#�delegate.name
					�"�swaggerApiOperationResponse��ENDIF�)
		'''
	}

	def String swaggerApiOperationResponse(ResourceOperation it) {
		if (httpMethod == HttpMethod::DELETE && path.contains("{id}")
				&& !parameters.exists[e | e.name == "id"]) {
			val domainObjectName = parameters.filter[e | e.domainObjectType
				!= null].head?.domainObjectType.name
			if (domainObjectName != null)
				return ''', response = �domainObjectName�.class'''
		}

		val type = delegate.typeName
		if (type == "void")
			return ""

		val collection = JAXRSHelper.COLLECTIONS.filter[type.startsWith(it)].head
		return ''', �IF collection != null�response = �type.substring(collection
			.length + 1, type.length - 1)�.class, responseContainer = "�collection
				.substring(collection.lastIndexOf('.') + 1)�"�ELSE�response = �type
					�.class�ENDIF�'''
	}
}
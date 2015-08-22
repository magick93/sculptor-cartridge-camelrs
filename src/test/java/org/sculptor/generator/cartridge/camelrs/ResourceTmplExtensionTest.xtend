package org.sculptor.generator.cartridge.camelrs

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

/**
 * Tests that verify that Camel REST DSL builders are correctly generated
 */
class ResourceTmplExtensionTest extends GeneratorTestBase {

	static val TEST_NAME = "camelrs"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertLibraryResourceRouteBuilder() {
		val code = getFileText(TO_GEN_SRC + "/org/helloworld/planet/rest/PlanetResourceImpl.java");
		println(code);
		assertContains(code, "PlanetResourceImpl extends RouteBuilder {")
		assertContains(code, "rest(\"/planet\")");
		assertContains(code, "get(\"/{id}\")");
		assertContains(code, "produces(MediaType.APPLICATION_JSON)");
		assertContains(code, "to(\"direct:show\")");
		assertContains(code, "get(\"/form\")");
		assertContains(code, "produces(MediaType.APPLICATION_JSON)");
		assertContains(code, "to(\"direct:createForm\")");
		assertContains(code, "post(\"/\")");
		assertContains(code, "produces(MediaType.APPLICATION_JSON)");
		assertContains(code, "to(\"direct:create\")");
		assertContains(code, "delete(\"/{id}\")");
		assertContains(code, "produces(MediaType.APPLICATION_JSON)");
		assertContains(code, "to(\"direct:delete\")");
		assertContains(code, "get(\"/\")");
		assertContains(code, "produces(MediaType.APPLICATION_JSON)");
		assertContains(code, "to(\"direct:showAll\")");
	}
	
	@Test
	def void assertRouteWithDTOIsAbstract() {
		val code = getFileText(TO_GEN_SRC + "/org/helloworld/planet/rest/PlanetResourceImpl.java");
		assertContains(code, "abstract class")
		assertContains(code, "protected abstract void createRouteDirectUpdate();")	
		assertContains(code, "put(\"/\")")
		assertContains(code, "type(PlanetForm.class).to(\"direct:update\")")
	}
	
	@Test
	def void assertNonDelegatedRouteIsAbstract() {
		val code = getFileText(TO_GEN_SRC + "/org/helloworld/planet/rest/PlanetResourceImpl.java");
		assertContains(code, "abstract class")
		assertContains(code, "protected abstract void createRouteDirectCreateForm();")	
		assertContains(code, "get(\"/form\")")
		assertContains(code, "to(\"direct:createForm\")")
	}


	@Test
	def void assertLibraryResourceImplementation() {
		val code = getFileText(
			TO_SRC + "/org/helloworld/planet/rest/PlanetResource.java")
		assertNotContains(code, "@Controller")
		assertContainsConsecutiveFragments(code, #[
			"public class PlanetResource extends PlanetResourceImpl {",
			"public PlanetResource() {",
			"}"
		])
	}
}

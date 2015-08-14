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
		println(runGenerator(TEST_NAME))
	}

	@Test
	def void assertLibraryResourceRouteBuilder() {
		val code = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/media/rest/LibraryResourceBase.java");
		println(code);
		assertContains(code, "LibraryResourceBase  extends RouteBuilder{")
		assertContainsConsecutiveFragments(code, #[
			"public void configure() throws Exception {",
			"rest(\"/media\")",
			".get(\"/{name}\")",
			".produces()",
			".to(\"direct:show\")",
			".get(\"/form\")",
			".produces()",
			".to(\"direct:createForm\")",
			".post(\"/\")",
			".produces()",
			".to(\"direct:create\")",
			".get(\"/\")",
			".produces()",
			".to(\"direct:showAll\")"
		])
	}


	@Test
	def void assertLibraryResourceImplementation() {
		val code = getFileText(
			TO_SRC + "/org/sculptor/example/library/media/rest/LibraryResource.java")
		// FIXME: No spring @Controller should be present
		//assertNotContains(code, "@Controller")
		assertContainsConsecutiveFragments(code, #[
			"public class LibraryResource extends LibraryResourceBase {",
			"public LibraryResource() {",
			"}"
		])
	}
}

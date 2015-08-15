package org.sculptor.generator.cartridge.camelrs

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

/**
 * Tests that verify that JAX-RS Application are correctly generated
 */
class ServiceTmplExtensionTest extends GeneratorTestBase {
	
	private static val APPLICATION_EXTENSION = "camelrs"
	
	new() {
		super(APPLICATION_EXTENSION)
	}
	
	@BeforeClass
	def static void setup() {
		runGenerator(APPLICATION_EXTENSION)
	}
	
	@Test
	def void assertCorrectPackageName() {
		assertContains(service, "@Named(\"planetService\")");
		assertContainsConsecutiveFragments(service, #[
			"@Inject",
			"private PlanetRepository planetRepository"
		]);
	}
	
	def getService() {
		getFileText(TO_GEN_SRC + "/org/helloworld/planet/serviceimpl/PlanetServiceImpl.java")
	}
}
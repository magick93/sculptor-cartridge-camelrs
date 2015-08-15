package org.sculptor.generator.cartridge.camelrs

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.test.GeneratorTestBase

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

/**
 * Tests that verify that JAX-RS Application are correctly generated
 */
class RestWebTmplExtensionTest extends GeneratorTestBase {
	
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
		application.assertContains("package org.helloworld.rest")
	}
	
	@Test
	def void assertCorrectlyAddsResources() {
		application.assertContains("import org.helloworld.planet.rest.PlanetResourceImpl")
		application.assertContains("classes.add(PlanetResourceImpl.class)")
	}
	
	def getApplication() {
		getFileText(TO_GEN_SRC + "/org/helloworld/rest/RestApplication.java")
	}
}
# sculptor-cartridge-camelrs
Sculptor Cartridge for rest services using Apache Camel

To use this in your Sculptor project, there are 2 changes to make:

1. In your pom.xml add a dependency to the sculptor plugin:
```
				<dependencies>
	                <dependency>
						<groupId>org.sculptorgenerator</groupId>
						<artifactId>sculptor-cartridge-camelrs</artifactId>
						<version>3.1.0</version>
					</dependency>
         		</dependencies>

```

2. In your sculptor-generator.properties enable the cartridge with:
```
cartridges=builder, camelrs
```

## CamelRS generator configuration
Define this properties in you sculptor-generator.properties to control CamelRS
endpoints generation.

*deployment.contextRoot* - controls context root CamelRS will be using to bind it services to.
This is a required property. Set it to context root you're planning to deploy resulting WAR file to.

*camelrs.restPath* - controls the path CamelRS will bind rest services to.
By default set to 'contextRoot'. Override it if you need different path for CamelRS services.

*camelrs.idToEntityMappingMethod* - controls service method that will be used to map between ID and Entity.
By default set to 'findById'. Override it if you're using another naming convention.

## Example web.xml generator
Some services (CamelRS for instance) require addtional setup done in web.xml. Example web.xml generator
builds basic web.xml providing initial configuration for those services. It's located in src/generated/resources directory. 
Copy web_example.xml to src/main/webapp/WEB-INF/web.xml and edit it to fine tune it's parameters.

*generate.web.example* - controls generation of web_example.xml file.
By default set to 'true'. Set it to false to disable web_example.xml generation.
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

*deployment.contextPath* - controls context path CamelRS will be using to bind it services to.
This is a required property. Set it to context path you're planning to deploy resulting WAR file to.

*camelrs.idToEntityMappingMethod* - controls service method that will be used to map between ID and Entity.
By default set to 'findById'. Override it if you're using another naming convention.



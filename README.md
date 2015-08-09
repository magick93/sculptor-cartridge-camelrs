# sculptor-cartridge-camelrs
Sculptor Cartridge for rest services using Apache Camel

To use this in your Sculptor project, there are 3 changes to make:

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

2. In your pom.xml add a dependency the previous as a dependency

```
				
	                <dependency>
						<groupId>org.sculptorgenerator</groupId>
						<artifactId>sculptor-cartridge-camelrs</artifactId>
						<version>3.1.0</version>
					</dependency>
```

3. In your sculptor-generator.properties enable the cartridge with:
```
cartridges=builder, camelrs
```

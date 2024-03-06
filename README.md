# Robocode Coding Challenge

## Resources
* Robocode Homepage: https://robocode.sourceforge.io/
* Robocode Wiki: https://robowiki.net/wiki
* Robocode Wiki - interessante Seiten:
  * https://robowiki.net/wiki/Targeting
  * https://robowiki.net/wiki/Radar
  * https://robowiki.net/wiki/Movement

## Worum geht es
Jedes Team hat seinen eigenen vorbereiteten Arbeitsplatz. Ziel ist es, einen kampffähigen Roboter zu coden,
der dann gegen die Roboter der anderen Teams antritt.

Um eine neue Version während der Veranstaltung ins Rennen zu schicken, genügt ein `git push` (nach 1-n Commits natürlich) und nach bis zu einer Minute wird der Roboter am Demorechner im Hintergrund gebaut und der Wettkampf wird dann neu gestartet.

## Regeln
* Jedes Team arbeitet ausschließlich am eigenen, vorbereiteten Branch
* Jedes Team muss seinen Roboter _selbst schreiben_, d.h. kein ChatGPT, CoPilot usw.
* Am Ende der Veranstaltung treten die finalen Versionen der Teams gegeneinander an

## How To

### Name ändern
Im `pom.xml` der Projekts kann und soll der Name des Roboters geändert werden. Das dafür zuständige Property
ist in Zeile 13 zu finden:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.bearingpoint</groupId>
    <artifactId>robot</artifactId>
    <version>0.1-SNAPSHOT</version>

    <properties>
        <!-- Must be a valid Java class name -->
        <robot.name>OptimusPrime</robot.name> <!-- <<<<< there <<<<< -->

        <!-- ... -->
    </properties>
    <!-- ... -->
</project>
```

## Farben anpassen
In der Klasse `MyRobot` kann der Roboter nun angepasst werden, indem folgende Methode innerhalb von `run()` aufgerufen wird (derzeit in Zeile 16):

```java
setColors(
	Color bodyColor,
	Color gunColor,
	Color radarColor,
	Color bulletColor,
	Color scanArcColor);
```

## Verhalten
In der `while`-Schleife kann das Verhalten das Verhalten des Roboters implementiert werden. Aktuell ist ein sehr einfacher
Algorithmus implementiert:

```java
while (true) {
	ahead(100);

	if (random.nextBoolean()) {
		turnGunLeft(45);
		turnGunRight(90);
		turnGunLeft(45);

		turnRight(90);
	} else {
		turnGunRight(45);
		turnGunLeft(90);
		turnGunRight(45);

		turnLeft(90);
	}
}
```
Außerdem ist es ratsam, folgende, bestehende Methoden zu überarbeiten:
* `onScannedRobot(...)`
* `onHitByBullet(...)`
* `onHitWall(...)`

In der Basisklasse `Robot` sind noch weitere Methoden inkl. Dokumentation zu finden,
die ausprogrammiert werden könnten.

package com.bearingpoint.robocode;

import robocode.HitByBulletEvent;
import robocode.HitWallEvent;
import robocode.Robot;
import robocode.ScannedRobotEvent;

import java.awt.*;
import java.util.Random;

public class MyRobot extends Robot {

    public void run() {
        Random random = new Random();

        setColors(
                Color.DARK_GRAY,
                Color.GREEN,
                Color.ORANGE,
                Color.YELLOW,
                Color.LIGHT_GRAY
        );

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
    }

    /**
     * What to do when you see another robot
     */
    @Override
    public void onScannedRobot(ScannedRobotEvent e) {
        // Replace the next line with any behavior you would like
        fire(1);
    }

    /**
     * What to do when you're hit by a bullet
     */
    @Override
    public void onHitByBullet(HitByBulletEvent e) {
        // Replace the next line with any behavior you would like
        back(10);
    }

    /**
     * What to do when you hit a wall
     */
    @Override
    public void onHitWall(HitWallEvent e) {
        // Replace the next line with any behavior you would like
        back(20);
    }

}

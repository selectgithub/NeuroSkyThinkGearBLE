package com.chris.thinkgearble_androidstudio;

/**
 * Created by mac on 19/11/2016.
 */

public class EEGPower {

    public int delta,theta,lowAlpha,highAlpha,lowBeta,highBeta,lowGamma,middleGamma;

    @Override
    public String toString() {
        return "Delta: " + delta + "\nTheta: " + theta +
                "\nLowAlpha: " + lowAlpha + "\nHighAlpha: " + highAlpha +
                "\nLowBeta: " + lowBeta + "\nHighBeta: " + highBeta +
                "\nLowGamma: " + lowGamma + "\nMiddleGamma: " + middleGamma;
    }
}

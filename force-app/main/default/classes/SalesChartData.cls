/**
 * Represents a single data point for a dashboard chart.
 */
public with sharing class SalesChartData {

    @AuraEnabled
    public String label;

    @AuraEnabled
    public Decimal value;

}
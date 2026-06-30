/* Wrapper class that represents the sales dashboard data required by the 
Interactive Sales Dashboard */
public with sharing class SalesDashboardWrapper {
    
    @AuraEnabled
    public Integer totalAccounts;

    @AuraEnabled
    public Integer totalOpportunities;

    @AuraEnabled
    public Decimal totalRevenue;

    @AuraEnabled
    public Decimal closedWonRevenue;

    @AuraEnabled
    public List<SalesChartData> revenueByStageData;

    @AuraEnabled
    public List<SalesChartData> monthlyRevenueData;

    @AuraEnabled
    public List<SalesChartData> opportunityIndustryData;

    @AuraEnabled
    public List<Map<String, Object>> mapMarkers;

    @AuraEnabled
    public List<opportunity> recentOpportunities;


    
}
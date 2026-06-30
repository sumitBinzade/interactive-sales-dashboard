/**
 * Controller for the Interactive Sales Dashboard.
 * Provides all data required by the dashboard LWC.
 */
public with sharing class SalesDashboardController {

    @AuraEnabled(cacheable=true)
    public static SalesDashboardWrapper getDashboardData(String stageName, String industry) {

        SalesDashboardWrapper dashboardWrapper = new SalesDashboardWrapper();

        loadMetrics(dashboardWrapper);
        loadRevenueByStageData(dashboardWrapper);
        loadMonthlyRevenueData(dashboardWrapper);
        loadOpportunityIndustryData(dashboardWrapper);
        loadMapMarkers(dashboardWrapper);
        loadRecentOpportunities(dashboardWrapper);

        return dashboardWrapper;
    }

    private static void loadMetrics(SalesDashboardWrapper dashboardWrapper) {
        dashboardWrapper.totalAccounts = [SELECT COUNT() FROM Account];

        AggregateResult opportunityMetrics = [SELECT COUNT(Id) totalOpportunities, SUM(Amount) totalRevenue
        FROM Opportunity];

        dashboardWrapper.totalOpportunities = (Integer)opportunityMetrics.get('totalOpportunities');

        Object totalRevenue = opportunityMetrics.get('totalRevenue');
        dashboardWrapper.totalRevenue = totalRevenue != null ? (Decimal)totalRevenue : 0;

        AggregateResult closedWonMetrics = [SELECT SUM(Amount) closedWonRevenue
        FROM Opportunity WHERE StageName = 'Closed Won'];

        Object closedWonRevenue = closedWonMetrics.get('closedWonRevenue');

        dashboardWrapper.closedWonRevenue = closedWonRevenue != null ? (Decimal) closedWonRevenue : 0;

    }

    private static void loadRevenueByStageData(SalesDashboardWrapper dashboardWrapper) {
        dashboardWrapper.revenueByStageData = new List<SalesChartData>();

        List<AggregateResult> results = [SELECT StageName, SUM(Amount) totalRevenue
        FROM Opportunity GROUP BY StageName ORDER BY StageName];

        for (AggregateResult result : results) {
            SalesChartData chartData = new SalesChartData();

            chartData.label = (String)result.get('StageName');
            Object totalRevenue = result.get('totalRevenue');
            chartData.value = totalRevenue != null ? (Decimal) totalRevenue : 0;

            dashboardWrapper.revenueByStageData.add(chartData);
        }

    }

    private static void loadMonthlyRevenueData(SalesDashboardWrapper dashboardWrapper) {
        dashboardWrapper.monthlyRevenueData = new List<SalesChartData>();

        List<AggregateResult> results = [SELECT CALENDAR_YEAR(CloseDate) salesYear, CALENDAR_MONTH(CloseDate) salesMonth, 
        SUM(Amount) totalRevenue FROM Opportunity GROUP BY CALENDAR_YEAR(CloseDate), CALENDAR_MONTH(CloseDate) ORDER BY CALENDAR_YEAR(CloseDate), CALENDAR_MONTH(CloseDate)];

        List<String> monthNames = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

        for(AggregateResult result : results){
            SalesChartData chartData = new SalesChartData();

            Integer year = (Integer)result.get('salesYear');
            Integer month = (Integer)result.get('salesMonth');
            chartData.label = monthNames[month - 1] + ' ' + year;
            Object totalRevenue = result.get('totalRevenue');
            chartData.value = totalRevenue != null ? (Decimal) totalRevenue : 0;

            dashboardWrapper.monthlyRevenueData.add(chartData);
        }

    }

    private static void loadOpportunityIndustryData(SalesDashboardWrapper dashboardWrapper) {

        dashboardWrapper.opportunityIndustryData = new List<SalesChartData>();

        List<AggregateResult> results = [SELECT Account.Industry industry, COUNT(Id) opportunityCount FROM Opportunity
        WHERE Account.Industry != NULL GROUP BY Account.Industry ORDER BY COUNT(Id) DESC];

        for(AggregateResult result : results){
            SalesChartData chartData = new SalesChartData();

            chartData.label = (String)result.get('industry');
            chartData.value = (Integer)result.get('opportunityCount');

            dashboardWrapper.opportunityIndustryData.add(chartData);
        }
    }

    private static void loadMapMarkers(SalesDashboardWrapper dashboardWrapper) {
        dashboardWrapper.mapMarkers = new List<Map<String, Object>>();

        List<Account> accountList = [SELECT Name, Industry, BillingCity, BillingState, BillingCountry FROM Account WHERE BillingCity != NULL];

        for(Account accountRecord : accountList){
            Map<String, Object> marker = new Map<String, Object>();
            
            marker.put('location', 
            new Map<String, String>{
                'City' => accountRecord.BillingCity,
                'State' => accountRecord.BillingState,
                'Country' => accountRecord.BillingCountry
            });
            marker.put('title', accountRecord.Name);
            marker.put('description', accountRecord.Industry != null ? accountRecord.Industry : 'Industry Not Available');

            dashboardWrapper.mapMarkers.add(marker);
        }

    }

    private static void loadRecentOpportunities(SalesDashboardWrapper dashboardWrapper) {
        dashboardWrapper.recentOpportunities = [SELECT Id, Name, StageName, Amount, CloseDate, Account.Name FROM Opportunity
        ORDER BY LastModifiedDate DESC LIMIT 10];
    }
}
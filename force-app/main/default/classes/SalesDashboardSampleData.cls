/* 
    This is a sample data class for the Sales Dashboard component.
    It can be used to generate sample data for testing and demonstration purposes. 
*/
public with sharing class SalesDashboardSampleData {
    public static void generateData(){

        deleteExistingSampleData();

        List<Account> accounts = createAccounts();

        createOpportunities(accounts);
    }

    private static void deleteExistingSampleData(){
        List<Opportunity> opportunitiesToDelete = [SELECT Id FROM Opportunity WHERE Name LIKE 'Sales Dashboard Opportunity%'];

        if(!opportunitiesToDelete.isEmpty()){
            delete opportunitiesToDelete;
        }
        
        List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Name LIKE 'Sales Dashboard Account%'];

        if(!accountsToDelete.isEmpty()){
            delete accountsToDelete;
        }
    }

    private static List<Account> createAccounts(){
        List<Account> accounts = new List<Account>();

        List<String> industries = new List<String>{'Technology', 'Finance', 'Healthcare', 'Retail', 'Manufacturing'};
        List<String> cities = new List<String>{'New York', 'San Francisco', 'Chicago', 'Los Angeles', 'Boston'};
        List<String> states = new List<String>{'New York', 'California', 'Illinois', 'California', 'Massachusetts'};

        for(Integer i = 1; i <= 25; i++){

            Integer index = Math.mod(i - 1, industries.size());
            accounts.add(new Account(
                Name = 'Sales Dashboard Account ' + i  ,
                Industry = industries[index],
                BillingCity = cities[index],
                BillingState = states[index],
                BillingCountry = 'United States'
            ));
        }
        insert accounts;

        return accounts;
    } 

    private static void createOpportunities(List<Account> accounts){

        List<Opportunity> opportunities = new List<Opportunity>();

        List<String> stages = new List<String>{'Prospecting', 'Qualification', 'Needs Analysis', 'Value Proposition', 'Id. Decision Makers', 'Perception Analysis', 'Proposal/Price Quote', 'Negotiation/Review', 'Closed Won', 'Closed Lost'};

        Integer opportunityCounter = 1;

        for(Account account : accounts){
            for(Integer j = 0; j < 3; j++){
                opportunities.add(new Opportunity(
                    Name = 'Sales Dashboard Opportunity ' + opportunityCounter,
                    AccountId = account.Id,
                    StageName = stages[Math.mod(opportunityCounter - 1, stages.size())],
                    CloseDate = Date.today().addDays(Math.mod(opportunityCounter * 10, 180)),
                    Amount = 50000 + (opportunityCounter * 10000)
                ));

                opportunityCounter++;
            }
        }
        insert opportunities;

    }
}
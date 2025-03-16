public with sharing class FX_AccountContractController {
    

    // Wrapper class to send both data and errors
    public class ResponseWrapper {
        @AuraEnabled public List<FX_Account_Contract_Clause__c> data;
        @AuraEnabled public String error;
    }
    
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getAccountContractClauses(Id accountId) {

        ResponseWrapper response = new ResponseWrapper();
        
        try
        {

                if(accountId == null)
                {
                    
                    response.error = Label.fx_Account_Id_Missing;
                    return response; // Return response with error
           
                }
                
                //Fetch the Account details from the accountId
                
                Account acc = [Select BillingCountry from Account where Id =:accountId];
        
                //if the billingcountry is null it should sent back a response that as billingcountry is empty

                if (String.isBlank(acc.BillingCountry))
                {
                    response.error = Label.fx_Account_Billing_Country_Missing;
                    return response; // Return response with error
                }

                //fetch all associated Account Contract Clauses for the respective Account
                response.data = [Select Id,Name,FX_Account_Contract__r.Name,FX_Billing_Country__c,FX_IsValid__c 
                                                                                                                  FROM  FX_Account_Contract_Clause__c
                                                                                                                  WHERE FX_Account_Contract__c IN
                                                                                                                        (Select Id from FX_Account_Contract__c where FX_Account__c =:accountId)  ];
                //if the response data is missing
                if(response.data.size() == 0)
                {
                    response.error = Label.fx_Account_Contract_Clauses_Missing;
                    return response; // Return response with error
                }                                                                                                   
                
        } 
        catch (Exception e) {
            response.error = Label.fx_Unexpected_Error + e.getMessage();
        }
        
        return response;

    }

    @AuraEnabled
    public static void createAccountContracts(Id accountId, List<Id> clauseIds){
        try 
        {

            //insert the accountContract based on accountId
            FX_Account_Contract__c accountContract = new FX_Account_Contract__c(FX_Account__c=accountId,FX_Status__c ='Active');
            insert accountContract;
            System.debug('Account Contract Id:'+accountContract.Id);

            

            //Create a collection of AccountContractClauses to insert new records
            List<FX_Account_Contract_Clause__c> clausesToUpdate = new List<FX_Account_Contract_Clause__c>();

            List<String> clauseStringCollection = new List<String>();
            
            //looping through the existing clauses
            
            for(Id clauseId :clauseIds)
            {
                FX_Account_Contract_Clause__c clausetoUpdate = new FX_Account_Contract_Clause__c();
                clausetoUpdate.FX_Account_Contract__c = accountContract.Id;
                System.debug('Updated clause contract Id:'+clausetoUpdate.FX_Account_Contract__c );
                clausetoUpdate.id = clauseId;
                clausesToUpdate.add(clausetoUpdate);
               
            }

            //updating the clauses to the new contract created
            update clausesToUpdate;

            

            //save a copy of the displayed information as a file that is linked to Account Contract record

            List<FX_Account_Contract_Clause__c> clausesNameCollection = new List<FX_Account_Contract_Clause__c>([Select Name,FX_Account_Contract__r.Name,FX_Billing_Country__c,FX_IsValid__c from FX_Account_Contract_Clause__c where Id =:clauseIds]);
            for(FX_Account_Contract_Clause__c clause :clausesNameCollection)
            {
                clauseStringCollection.add(clause.Name+'--'+clause.FX_Account_Contract__r.Name+'--'+clause.FX_Billing_Country__c+'--'+clause.FX_IsValid__c);
            }
            String clauseText = String.join(clauseStringCollection, '\n');
            ContentVersion cv = new ContentVersion(
            Title = Label.fx_ClauseFileName,
            PathOnClient = 'ContractClauses.txt',
            VersionData = Blob.valueOf(clauseText),
            FirstPublishLocationId = accountContract.Id
            );
            insert cv;

            
            
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        
    }
}
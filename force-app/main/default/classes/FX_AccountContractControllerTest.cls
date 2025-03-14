/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *

 */
@isTest
private class FX_AccountContractControllerTest {

    
    @testSetup
    static void setupTestData() {

        
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'United States');
        insert testAccount;

        // Create a test Account Contract
        FX_Account_Contract__c testContract = new FX_Account_Contract__c(FX_Account__c = testAccount.Id, FX_Status__c = 'Active');
        insert testContract;

        // Create test Account Contract Clauses
        List<FX_Account_Contract_Clause__c> clauses = new List<FX_Account_Contract_Clause__c>();
        for (Integer i = 0; i < 3; i++) {
            clauses.add(new FX_Account_Contract_Clause__c(
                
                FX_Account_Contract__c = testContract.Id,
                FX_Billing_Country__c = 'United States',
                FX_IsValid__c = true
            ));
        }
        insert clauses;
    }

    @isTest
    static void testGetAccountContractClauses() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        FX_AccountContractController.ResponseWrapper response = FX_AccountContractController.getAccountContractClauses(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(3, response.data.size(), 'Expected 3 contract clauses');
        System.assertEquals(null, response.error, 'Error should be null');
    }

    @isTest
    static void testGetAccountContractClauses_NoBillingCountry() {
        Account noBillingAccount = new Account(Name = 'No Billing Account');
        insert noBillingAccount;
        
        Test.startTest();
        FX_AccountContractController.ResponseWrapper response = FX_AccountContractController.getAccountContractClauses(noBillingAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(null, response.data, 'Data should be null');
        System.assertEquals(Label.fx_Account_Billing_Country_Missing, response.error, 'Expected error message found');
    }

    @isTest
    static void testGetAccountContractClauses_NoClauses() {
        Account newAccount = new Account(Name = 'New Account', BillingCountry = 'United States');
        insert newAccount;
        
        Test.startTest();
        FX_AccountContractController.ResponseWrapper response = FX_AccountContractController.getAccountContractClauses(newAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(Label.fx_Account_Contract_Clauses_Missing, response.error, 'Expected error message found');
    }

    
    @isTest
    static void testCreateAccountContracts() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        FX_Account_Contract__c testcontract = [Select Id from FX_Account_Contract__c limit 1];
        List<FX_Account_Contract_Clause__c> existingClauses = [SELECT Id FROM FX_Account_Contract_Clause__c LIMIT 2];
        List<Id> clauseIds = new List<Id>();
        for (FX_Account_Contract_Clause__c clause : existingClauses) {
            clauseIds.add(clause.Id);
        }
        
        Test.startTest();
        FX_AccountContractController.createAccountContracts(testAccount.Id, clauseIds);
        Test.stopTest();
        
        // Use an explicit wait (query again to ensure new records are committed)
        List<FX_Account_Contract__c> contracts = [SELECT Id FROM FX_Account_Contract__c WHERE FX_Account__c = :testAccount.Id ORDER BY CreatedDate DESC LIMIT 2];

        System.assert(contracts.size() > 1, 'New contract should be created');
        FX_Account_Contract__c createdContract = contracts[1];
        
        List<FX_Account_Contract_Clause__c> updatedClauses = [SELECT Id, FX_Account_Contract__c FROM FX_Account_Contract_Clause__c WHERE Id IN :clauseIds];
        for (FX_Account_Contract_Clause__c clause : updatedClauses) {
            System.assertEquals(createdContract.Id, clause.FX_Account_Contract__c, 'Clause should be linked to new contract');
        }
        
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId = :createdContract.Id];
        System.assert(contentVersions.size() > 0, 'ContentVersion should be created');
    
}

}
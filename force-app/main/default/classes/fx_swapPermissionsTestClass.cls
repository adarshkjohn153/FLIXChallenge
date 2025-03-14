/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 
 */
@isTest
public class fx_swapPermissionsTestClass {
    @isTest
    static void testSwapPermission() {
        // Create test Permission Sets
        PermissionSet permSet1 = new PermissionSet(Label='Test PermSet 1',Name = 'Test_PermSet_1');
        insert permSet1;
        PermissionSet permSet2 = new PermissionSet(Label='Test PermSet 2',Name = 'Test_PermSet_2');
        insert permSet2;
        
        // Create test Object Permissions
        ObjectPermissions objPerm1 = new ObjectPermissions(
            ParentId = permSet1.Id, SObjectType = 'FX_Account_Contract__c',
            PermissionsRead = true, PermissionsEdit = true,
            PermissionsCreate = true, PermissionsDelete = true,
            PermissionsViewAllRecords = false, PermissionsModifyAllRecords = false
        );
        insert objPerm1;
        
        ObjectPermissions objPerm2 = new ObjectPermissions(
            ParentId = permSet2.Id, SObjectType = 'FX_Account_Contract_Clause__c',
            PermissionsRead = true, PermissionsEdit = true,
            PermissionsCreate = true, PermissionsDelete = true,
            PermissionsViewAllRecords = false, PermissionsModifyAllRecords = false
        );
        insert objPerm2;
        
        // Create test Field Permissions
        FieldPermissions fieldPerm1 = new FieldPermissions(
            ParentId = permSet1.Id, SObjectType = 'FX_Account_Contract__c',Field = 'FX_Account_Contract__c.FX_Status__c',
            PermissionsRead = true, PermissionsEdit = true
        );
        insert fieldPerm1;
        
        FieldPermissions fieldPerm2 = new FieldPermissions(
            ParentId = permSet2.Id, SObjectType = 'FX_Account_Contract_Clause__c',Field = 'FX_Account_Contract_Clause__c.FX_Billing_Country__c',
            PermissionsRead = true, PermissionsEdit = true
        );
        insert fieldPerm2;

        // Create test Tab Settings
        PermissionSetTabSetting tabSetting1 = new PermissionSetTabSetting(
            ParentId = permSet1.Id, Name = 'FX_Account_Contract__c', Visibility = 'DefaultOn'
        );
        insert tabSetting1;
        
        PermissionSetTabSetting tabSetting2 = new PermissionSetTabSetting(
            ParentId = permSet2.Id, Name = 'FX_Account_Contract_Clause__c', Visibility = 'DefaultOn'
        );
        insert tabSetting2;
        
        // Call the swap method
        Test.startTest();
        fx_swapPermissions.swapPermission(permSet1.Id, permSet2.Id);
        Test.stopTest();
        
        // Verify that the permissions have been swapped
        ObjectPermissions swappedObjPerm1 = [SELECT ParentId, SObjectType FROM ObjectPermissions WHERE SObjectType = 'FX_Account_Contract__c' AND ParentId = :permSet2.Id LIMIT 1];
        System.assertEquals(permSet2.Id, swappedObjPerm1.ParentId);
        
        ObjectPermissions swappedObjPerm2 = [SELECT ParentId, SObjectType FROM ObjectPermissions WHERE SObjectType = 'FX_Account_Contract_Clause__c' AND ParentId = :permSet1.Id LIMIT 1];
        System.assertEquals(permSet1.Id, swappedObjPerm2.ParentId);
        
        FieldPermissions swappedFieldPerm1 = [SELECT ParentId, Field FROM FieldPermissions WHERE Field = 'FX_Account_Contract__c.FX_Status__c' AND ParentId = :permSet2.Id LIMIT 1];
        System.assertEquals(permSet2.Id, swappedFieldPerm1.ParentId);
        
        FieldPermissions swappedFieldPerm2 = [SELECT ParentId, Field FROM FieldPermissions WHERE Field = 'FX_Account_Contract_Clause__c.FX_Billing_Country__c' AND ParentId = :permSet1.Id LIMIT 1];
        System.assertEquals(permSet1.Id, swappedFieldPerm2.ParentId);

        PermissionSetTabSetting swappedTabSetting1 = [SELECT ParentId, Name, Visibility FROM PermissionSetTabSetting WHERE Name = 'FX_Account_Contract__c' AND ParentId = :permSet2.Id LIMIT 1];
        System.assertEquals(permSet2.Id, swappedTabSetting1.ParentId);
        System.assertEquals('DefaultOn', swappedTabSetting1.Visibility);
        
        PermissionSetTabSetting swappedTabSetting2 = [SELECT ParentId, Name, Visibility FROM PermissionSetTabSetting WHERE Name = 'FX_Account_Contract_Clause__c' AND ParentId = :permSet1.Id LIMIT 1];
        System.assertEquals(permSet1.Id, swappedTabSetting2.ParentId);
        System.assertEquals('DefaultOn', swappedTabSetting2.Visibility);
    }
}
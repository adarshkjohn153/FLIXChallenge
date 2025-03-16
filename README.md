#FlixChallenge

Hereby I am explaining the tasks I have done for the 3 Flixchallenges.

##Task 1--Quick Action Development

--Created a new custom object "Account Contract(FX_Account_Contract__c)"
--Created 4 custom fields associated to this Object
      --Account(lookup relationship to the Standard Account Object)
      --Status(FX_Status__c)
      --Contract Start Date (	FX_Contract_Start_Date__c)
      --Contract End Date (FX_Contract_End_Date__c)

--Created next custom object "Account Contract Clause(FX_Account_Contract_Clause__c)"
--Created 3 custom fields associated to this Object
      --Account Contract(Lookup relationship associated to the Account Contract Object)
      --Billing Country(FX_Billing_Country__c)
      --isValid(FX_IsValid__c)

-- Developed the Lightning Web component(fx_AccountContractClauseQuickAction) as action Type as ScreenAction
-- Created the custom labels for displaying the different known errors.
--Developed the associated Apex controller class( Fx_AccountContractController) and Apex controller Test class(Fx_AccountContractControllerTest)

--Created the new action "Display Clauses" and added it to the account page layout.


##Task 2-- Permission Sets

--Created new permission Sets named "AccountContractPermission" & "Account Contract Clause Permission"
--AccountContractPermission permission set gives permission to the Account contract object the permission "Read,Create,Edit and Delete" and given the Edit access to all the custom fields.
--AccountContractClausePermission permission set gives permission to the Account contract Clause object the permission "Read,Create,Edit and Delete" and given the Edit access to all the custom fields.


Instructions for swapping the permissions between the Permission Sets is added in the package notes "Instructions for Data Loader to swap the permissions.txt" file is added in the scripts folder of VS code package.

Also written scripts via apex to swap the permissions.
--Created the apex class "fx_SwapPermissions" for executing this and written test class "fx_SwapPermissionsTest".



##Task 3-- Status notification

--Created the Status(	fx_Status__c) custom field in Account and made this field as a path in the Account page layout specific for admin.
--Created a email template "Notify Account Owner of Status Change" for designing the email template.
--Created a email alert "Notify the Account Owner about the Status Change in Account" to send the emails to the Account Owner.
--Created a flow "Notify the Account Owner about the Status Change" to send the email to Account Owner whenever the status value in Account get changed.

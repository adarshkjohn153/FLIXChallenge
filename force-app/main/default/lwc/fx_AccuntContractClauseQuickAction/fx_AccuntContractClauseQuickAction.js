import { LightningElement,api,track,wire } from 'lwc';
import getAccountContractClauses from '@salesforce/apex/FX_AccountContractController.getAccountContractClauses';
import createAccountContracts from '@salesforce/apex/FX_AccountContractController.createAccountContracts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class FX_accountContractClauseQuickAction extends LightningElement 
{

        @api recordId;
        @track isLoading=true;
        @track clauses =[];
        @track error='';

        //Getting the data from the apex class through the wire function
        @wire(getAccountContractClauses, {accountId:'$recordId'})
        handleContractClauses({error,data})
        
        {
            this.isLoading = false;
            //if data exists, it will display the list of AccountContractClauses
            if(data)
            {
                //if data is having error information
                if (data.error) {
                    this.error = data.error;
                    this.clauses = []; // Clear clauses if there's an error
                    this.showToast('Error', this.error, 'error');
                }
                else
                {
                    //if data contain the clause information, processes an array of objects (data.data) and maps it to a new array of transformed objects, which is then assigned to this.clauses.
                
                    this.clauses = data.data.map(clause =>({

                    Id:clause.Id,
                    Name:clause.Name,
                    ContractName :clause.FX_Account_Contract__r.Name,
                    BillingCountry :clause.FX_Billing_Country__c,
                    isValid :clause.FX_IsValid__c

                    }));
                    
                    this.error='';
                }   
            }
            //if there is error , show the error message.
            else if(error)
            {
                this.error = 'An unexpected error occurred while fetching data.';
                this.clauses = [];
                this.showToast('Error', this.error, 'error');
            }
        }


        handleProceed()
        {
            this.isLoading = true;

            //if the clauses doesnt exists for the account contracts
            if(this.clauses.length === 0)
            {
                this.showToast('Error','No Contract clauses present to proceed','error');
                this.isLoading=false;
                
                
            }
            else
            {
                //create the new Account Contracts for the clauses
                createAccountContracts({accountId: this.recordId, clauseIds:this.clauses.map(c=>c.Id)}) 

                .then(() => {
                    
                    this.showToast('Success','Account Contract Created Successfully!','success');
                    this.closeAction();
                })
                .catch(error => {
                    
                    this.showToast('Error','Failed creating Account Contract','error');
                    this.loading=false;
                    this.closeAction();
                });
                }
            }

        //closeQuickAction
        closeAction(){
            this.dispatchEvent(new CloseActionScreenEvent());
          }

        //Showtoast events

        showToast(title, message, variant) {
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        }

         
        

}
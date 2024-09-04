import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { createRecord } from "lightning/uiRecordApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import getRecordTypeId from '@salesforce/apex/FEP_CreateContactCase.getRecordTypeIdAndQueueOwner';
import getUserInfo from '@salesforce/apex/FEP_CreateContactCase.getUserInfo';
import AdminEmail from "@salesforce/label/c.FEP_AdminQueueEmail";
import isGuest from "@salesforce/user/isGuest";
import id from '@salesforce/user/Id';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import REASON_FIELD from '@salesforce/schema/Case.FEP_ReasonForContactingUs__c';
export default class Fep_contactUsForm extends NavigationMixin(LightningElement) {
    EMAIL_PATTERN = '[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$';
    options = [];
    defaultValue = '';
    selectedReason;
    isOtherSelected = false;
    isLoaded = false;
    fieldMap = {};
    errorMessage;
    successMessage;
    FEP_FirstName__c;
    FEP_LastName__c;
    FEP_Email__c;
    FEP_Mobile__c;
    FEP_CompanyName__c;
    recordType;
    isguest = isGuest;
   async connectedCallback(){
    try{
        let recordTypeIdandQueue = await getRecordTypeId({recordTypeName:'FEP_SchedulingSiteCase',sObjectName:'Case'});
        let recordTypeIdAndownerId= recordTypeIdandQueue.split(',');
        this.fieldMap['RecordTypeId'] = recordTypeIdAndownerId[0];
        this.recordType = recordTypeIdAndownerId[0];
        this.fieldMap['OwnerId'] = recordTypeIdAndownerId[1];
        this.fieldMap['Topic_1__c']='General Program Inquiry';
        this.fieldMap['Keyword_1__c']='Financial Wellness Website';
        this.fieldMap['FEP_NotificationEmailAddress__c']=AdminEmail;
        if(!this.isguest){
            let user = await getUserInfo({userId:id});
            if(user){
                this.FEP_FirstName__c=user?.FirstName;
                this.FEP_LastName__c=user?.LastName;
                this.FEP_Email__c = user?.Email;
                this.FEP_CompanyName__c =user?.Account?.Name;
                const mobile = user?.MobilePhone?.replaceAll('+1 ',"");
                const zip = mobile?.substring(0, 3);
                const middle = mobile?.substring(3, 6);
                const last = mobile?.substring(6, 10);
                this.FEP_Mobile__c = mobile?`${zip}-${middle}-${last}`:null;
                this.fieldMap['ContactId']= user?.ContactId;
            }
        }
        this.isLoaded=true
    }
    catch(error){
        this.errorMessage = error.message;
        console.error(error.message);
    }
   }

   @wire(getPicklistValues, { recordTypeId: '$recordType', fieldApiName: REASON_FIELD })
   picklistResults({ error, data }) {
    if (data) {
      let values = data.values;
      this.options = values;
      this.errorerrorMessage = undefined;
    } else if (error) {
      this.errorMessage = error;
      
    }
  }
 


    handleMobileChange(event) {
        const target = event.target;
        const input = event.target.value.replace(/\D/g, '').substring(0, 10); // First ten digits of input only
        const zip = input.substring(0, 3);
        const middle = input.substring(3, 6);
        const last = input.substring(6, 10);

        if (input.length > 6) { target.value = `${zip}-${middle}-${last}`; }
        else if (input.length > 3) { target.value = `${zip}-${middle}`; }
        this.inputValue = event.target.value;
    }

    handleComboChange(event) {
        this.selectedReason = event.detail.value;
        this.isOtherSelected = this.selectedReason === 'Other' ? true : false;
    }

    async handleContactUs() {
        try {
            const userInputs = this.template.querySelectorAll('[data-type="user-input"]');
            const allValid = [
                ...userInputs,
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

            if (allValid) {
                this.isLoaded = false;
                userInputs.forEach(input => {
                    let datasetName = input.dataset.name;
                    if (datasetName === 'FEP_Mobile__c') {

                        this.fieldMap[datasetName] = '+1 ' + input.value.replaceAll("-", "");
                    }
                    else {
                        this.fieldMap[datasetName] = input.value;
                    }

                });
                this.fieldMap['Origin'] = 'Web';
                let isSuccess = await createRecord({ apiName: CASE_OBJECT.objectApiName, fields: this.fieldMap });
                this.isLoaded = true;
                this.successMessage = true;
                this.errorMessage=null;
            }

        }
        catch (error) {
            this.isLoaded = true;
            this.successMessage=null;
            if (Array.isArray(error)) {
               this.errorMessage = error.map(e => e.message).join(', ');
            } else if (typeof error.message === 'string') {
                this.errorMessage= error.message;
              }
            console.error(errorMessage);
        }
    }

    handleExistingUser() {
        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `${basePath}/login`
                }
            });
        }
        catch (error) {
            console.error(error.message);
        }
    }

    handleAlert() {
        this.errorMessage = null
        this.successMessage=null
    }

}
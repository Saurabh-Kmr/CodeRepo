import { LightningElement, api } from 'lwc';
import getAppointmentList from '@salesforce/apex/FEP_AppointmentList.getAllAppointmentsForContact';
import { NavigationMixin } from 'lightning/navigation';

export default class Fep_appintmentRelatedList extends NavigationMixin(LightningElement){


    @api recordId;
    recordList=[];
    showSpinner=false;
    showTable=false;

    

    connectedCallback(){  
        this.handleLoad();
    }


    handleLoad() {
        getAppointmentList({ contactId : this.recordId })
          .then((result) => {  
            if(result.length>0){ 
                this.recordList= result; 
                this.showTable = true;
            }else{
                this.showTable = false;
            }
          })
          .catch((error) => {
            this.error = error;
          });
    }

    navigateToRecord(event){
      const recordId = event.currentTarget.dataset.id;
    
      this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: recordId,
              actionName: 'view'
          }
      });
    }
 

    
}
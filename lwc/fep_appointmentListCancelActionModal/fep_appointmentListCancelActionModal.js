import { LightningElement,api,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getAppointmentDetails from '@salesforce/apex/FEP_AppointmentList.getAppointmentDetails';
import cancelAppointment from '@salesforce/apex/FEP_AppointmentList.cancelAppointment';

import { publish, MessageContext } from 'lightning/messageService';
import appointmentChannel from '@salesforce/messageChannel/FEP_AppointmentBookingChannel__c';

export default class Fep_appointmentListCancelActionModal extends LightningModal {


    @api content;

    showSpinner = false;
    servcApptNumber;
    servcApptDateTime;
    coachName;
    reason;
    showForm = true;


    @wire(MessageContext)
    messageContext;


    connectedCallback(){
        this.handleLoad();
    }

    handleLoad(){
        getAppointmentDetails({appointmentId : this.content.appointmentId})
        .then((result) => {
            console.log('result ::'+JSON.stringify(result));
            if(result){ 
                this.servcApptNumber = result.AppointmentNumber;
                this.servcApptDateTime = result.FEP_AppointmentDateTimeText__c;
                this.coachName = result.Assigned_Coach__r.Name;
            }
        })
        .catch((error) => {
            this.error = error;
        });  
    }

    handleReasonValue(event){
        this.reason = event.target?.value;
    }
    confirmCancel(){
        this.showSpinner = true;
        cancelAppointment({appointmentId : this.content.appointmentId,  reason : this.reason})
        .then((result) => {
            this.showSpinner = false; 
            if(result.includes('success')){ 
                this.showForm = false;
            }
        })
        .catch((error) => {
            this.error = error;
        });   
    }


    closeModal(){
        this.close();
        //publish event on LMS
        const payload = { recordId: this.serviceAppointmentId };
        publish(this.messageContext, appointmentChannel, payload);
    }
}
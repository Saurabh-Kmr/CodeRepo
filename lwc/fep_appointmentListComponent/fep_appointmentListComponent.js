import { LightningElement,wire,track,api } from 'lwc';
import Id from "@salesforce/user/Id";
import getAppointmentList from '@salesforce/apex/FEP_AppointmentList.getAppointmentList';
import fep_appointmentListActionModal from 'c/fep_appointmentListActionModal';
import fep_appointmentListCancelActionModal from 'c/fep_appointmentListCancelActionModal';
import FORM_FACTOR from '@salesforce/client/formFactor';
import fep_reScheduleAppointmentScreen from 'c/fep_reScheduleAppointmentScreen';
import formFactorPropertyName from "@salesforce/client/formFactor";
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import BASE_URL from '@salesforce/label/c.baseUrl';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import appointmentChannel from '@salesforce/messageChannel/FEP_AppointmentBookingChannel__c';



export default class Fep_appointmentListComponent extends  NavigationMixin(LightningElement) {
    baseUrl = BASE_URL;
    subscription = null;
    userId = Id;
    showTable = true; 
    recordOffset = 0;
    recordLimit = 0;
    disablePrevious=true;
    disableNext=false;
    totalRecords = 0;
    totalPages =1;
    currentPage=1;
    iconVariantPrev = 'bare-inverse';
    iconVariantNext = 'bare-inverse';
    @track recordsList=[];
    @track appointmentList = [];
    error;

    connectedCallback(){
        this.subscribeToMessageChannel();
        this.handleLoad();
    }


    handleLoad() {
        getAppointmentList({ userRecordId : this.userId })
          .then((result) => { 

            if(result.length>0){ 
                this.recordsList=null;
                this.recordsList= result;
                this.showRecords();
                this.showTable = true;
            }else{
                this.showTable = false;
            }
          })
          .catch((error) => {
            this.error = error;
          });
      }

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                appointmentChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            ); 
        }
    }

    // Handler for message received by component
    handleMessage(message) {
        this.currentPage =1;
        this.totalRecords = 0;
        this.totalPages =1;
        this.recordOffset = 0;
        this.recordLimit = 0;
        this.handlePrevious()
        this.handleLoad();
    }

    showRecords(){

        console.log(this.recordsList);

        if(this.recordsList.length > 0){
            this.totalRecords = this.recordsList.length;
            this.totalPages= Math.ceil(this.totalRecords/6);
    
            console.log("Total Records"+this.totalRecords)

            if((this.totalRecords - this.recordOffset) < 6 || this.totalRecords <= 6){
                this.disableNext = true;
                this.iconVariantNext = 'bare-inverse';
                this.appointmentList = this.recordsList.slice(this.recordOffset,this.totalRecords);
            }else{
               
               
                this.disableNext = false;
                this.iconVariantNext = 'brand'
                this.recordOffset = this.recordLimit;
                this.recordLimit +=6;
                this.appointmentList = this.recordsList.slice(this.recordOffset,this.recordLimit);
                    
                
                if(this.totalRecords - this.recordOffset < 6){
                    this.disableNext = true;
                    this.iconVariantNext = 'bare-inverse';
    
                }
    
            }
        }
    }

    handleNext(){

        this.showRecords();
        this.disablePrevious = false;
        this.iconVariantPrev = 'brand';
        this.currentPage +=1;
    }

    handlePrevious(){
        
        this.showNext = true;
        if(this.recordOffset == 0){

            this.disablePrevious = true;
            this.iconVariantPrev = 'bare-inverse';
        }else{
            this.recordOffset -= 6;
            this.recordLimit -=6;
            this.appointmentList = this.recordsList.slice(this.recordOffset,this.recordLimit);
            if(this.recordOffset == 0){
                this.disablePrevious = true;
                this.iconVariantPrev = 'bare-inverse';
                
            }
            this.currentPage -=1;
            this.disableNext = false;
            this.iconVariantNext = 'brand';
        }

    }


   async modifyAppointment(event){


    const coachId = event.target.dataset.coachid;
    const appointmentId = event.target.dataset.appointmentid
    const coachName = event.target.dataset.coachname;
    console.log(coachId);
    console.log(appointmentId);
    console.log(coachName);
       if(formFactorPropertyName == 'Small'){
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: this.baseUrl+`/reschedule-appointment?coachId=${coachId}&appointmentId=${appointmentId}&coachName=${coachName}&isCoachBios=${false}`
                    
                }
            }).then(url => {
                window.open(url, "_self")
            });
        }else{
        const result = await fep_reScheduleAppointmentScreen.open({
            size: 'medium',
            description: 'Accessible description of modal\'s purpose',
            content: {

                coachId:coachId,
                appointmentId:appointmentId,
                coachName:coachName,
                isCoachBios:false
            },
        });
    }
    }

    async cancelAppointment(event){

        const coachId = event.target.dataset.coachid;
        const appointmentId = event.target.dataset.appointmentid
        const coachName = event.target.dataset.coachname;
        console.log(coachId);
        console.log(appointmentId);
        console.log(coachName);
        const result = await fep_appointmentListCancelActionModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            content: {

                coachId:coachId,
                appointmentId:appointmentId,
                coachName:coachName
            },
        });

    }
    

    @api get message (){
        switch(FORM_FACTOR) {
            case 'Large':
            return 'You are on desktop';
            case 'Medium':
            return 'You are on tablet';
            case 'Small':
            return 'You are on mobile';
            default:
        }
    }

}
import { LightningElement,api,wire } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import getAllAppointments from '@salesforce/apex/Fep_ScheduleAppointmentController.getAllAppointments';
import getContactRecord from '@salesforce/apex/Fep_ScheduleAppointmentController.getContactRecord';
export default class Fep_financialCoachScreen extends LightningElement {
    recordId;
    @api serviceResourceOutputId;
    @api inputValue;
    @api parentRecord;
    @api contactId;
    @api financialCoach;
    @api inboundScheduling;
    @api outBoundFlowAvailable;
    @api selectedOption;
    @api serviceResourceName;
    @api validation;
    @api serviceResourceInputId;
    prevScheduleAppointment;
    optionSelected = '1';
    contactName;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
        }
    }
    connectedCallback(){
        console.log('serviceResourceOutputId'+this.serviceResourceOutputId);
        console.log('inputValue'+this.inputValue);
        console.log('parentRecord'+this.parentRecord);
        console.log('contactId'+this.contactId);
        console.log('financialCoach'+this.financialCoach);
        console.log('inboundScheduling'+this.inboundScheduling);
        console.log('outBoundFlowAvailable'+this.outBoundFlowAvailable);
        console.log('selectedOption'+this.selectedOption);
        console.log('serviceResourceName'+this.serviceResourceName);
        console.log('validation'+this.validation);
        console.log('serviceResourceInputId'+this.serviceResourceInputId);
        //this.serviceResourceOutputId = this.serviceResourceInputId;
        console.log('recordId'+this.recordId)
        if(this.recordId){
            getContactRecord({contactId:this.recordId}).then((data,error)=>{
                if(data){
                    this.contactName = JSON.parse(data)[0]?.Name;
                   
                }
            })
            getAllAppointments({contactId:this.recordId}).then((data,error)=>{
                if(data){
                    this.prevScheduleAppointment = JSON.parse(data);
                }
            })
        }
    }
    // handleChangeValue(event){
    //     if( event.detail?.value){
    //         this.serviceResourceOutputId = event.detail.value;
    //     }
    // }
    handlePrevCoachChange(event){
        console.log('coachId parent',event.detail.coachId);
        if( event.detail?.coachId){
            this.serviceResourceOutputId = event.detail.coachId;
        }  
    }
    handlePickerChange(event){
        if(event.detail?.recordId){
            this.serviceResourceOutputId = event.detail.recordId;
        }
    }
    handleRadioSelect(event){
        this.serviceResourceOutputId = '';


    }
    checkRadioButton(){
        let target = this.template.querySelector(`[data-id="radio-button"]`).checked = true;
        this.serviceResourceOutputId = '';
    }
    
}
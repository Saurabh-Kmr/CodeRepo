import { LightningElement,api,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getAllAvailableTimeSlotsForCoach from '@salesforce/apex/Fep_reScheduleAppointmentScreen.getAllAvailableTimeSlotsForCoach';
import userId from '@salesforce/user/Id';
import rescheduleServiceAppointments from '@salesforce/apex/Fep_reScheduleAppointmentScreen.rescheduleServiceAppointments';
import getTimeZoneList from '@salesforce/apex/Fep_ScheduleAppointmentController.getTimeZoneList';
import getSelectedTimeZone from '@salesforce/apex/Fep_ScheduleAppointmentController.getSelectedTimeZone';
import { publish, MessageContext } from 'lightning/messageService';
import appointmentChannel from '@salesforce/messageChannel/FEP_AppointmentBookingChannel__c';
import createServiceAppointments from '@salesforce/apex/Fep_ScheduleAppointmentController.createServiceAppointments';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import BASE_URL from '@salesforce/label/c.baseUrl';

export default class Fep_reScheduleAppointmentScreenMobile extends  NavigationMixin(LightningElement) {
    @api content;
    baseUrl = BASE_URL;
    showDate = true;
    inputDate;
    timeSlotToCoachData;
    timeSlots=[];
    showSlots;
    serviceAppointmentId;
    timeSelected;
    timeSelectedActualValue;
    prevTimeSelected;
    showAppointmentType;
    appointmentType;
    appointTypePhone = false;
    isButtonDisabled = true;
    serviceAppointmentRecord;
    coachSelected;
    reviewFormData=[];
    showReviewForm = false;
    coachSelectedId;

    showNoSlots = false;
    showCoach = false;
    showThankyouForm = false;
    isNextButtonDisabled = true;
    showTZOnLoad = true;
    tzOptions = [];
    selectedTimeZoneValue;
    selectedTimeZone;
    prevAppTypeSelected;
    isCoachBios;
    userRecord;
    appointmentDateTimeText;
    modelHeading;
    showSpinner = false;
    selectedValue;
    appEmailId;
    timeSlotDuration;
    additionalInformation;
    @wire(MessageContext)
    messageContext;
    thankyouMessage;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       
        if (currentPageReference) {
            this.coachSelectedId = currentPageReference.state.coachId || null;
            this.serviceAppointmentId = currentPageReference.state.appointmentId || null;
            this.coachSelected = currentPageReference.state.coachName || null;
            this.isCoachBios = currentPageReference.state.isCoachBios || null;
        

        }
    }

    connectedCallback(){
        this.handleLoad();
        this.handleSelectedTime();
       
    }
   
      handleTZChange(event){
        var selectedOptionLabel;
        this.showSlots = false;
        this.showCoach = false;
        this.prevTimeSelected = '';
        this.isNextButtonDisabled = true;

        this.selectedTimeZoneValue = event.detail.value;
        if(this.selectedTimeZoneValue != null && this.coachSelectedId != null){

            selectedOptionLabel = this.tzOptions.find(opt => opt.value === this.selectedTimeZoneValue);
            if(selectedOptionLabel){
                this.selectedTimeZone = selectedOptionLabel.label;
            }
         //  this.showSpinner = true;
            if(this.inputDate != null){
            this.fetchTimeSlots(this.inputDate,this.serviceAppointmentId,this.coachSelectedId,this.selectedTimeZoneValue);
        }
        }
       
       
      }

    
    handleLoad() {
        var picklistData=[];
        getTimeZoneList()
          .then((result) => {
                if(result){
                    result.forEach(item => {
                        const obj = {
                            label : item.tzLabel,
                            value : item.tzValue,
                        };
                       picklistData.push(obj);
                    });
                    this.tzOptions = picklistData;
                }
          })
          .catch((error) => {
            this.error = error;
          });
      }

      handleSelectedTime(){
        getSelectedTimeZone({ userRecId : userId})
        .then((result) => {
            if(result){ 
                this.selectedTimeZone = result.tzLabel;
                this.selectedTimeZoneValue = result.tzValue;
                this.selectedValue = result.tzValue;
                this.timeSlotDuration = Math.floor(result.slotduration);
            }
        })
        .catch((error) => {
            this.error = error;
        });
      }
    handleDateChange(event){
       
        this.inputDate = event.detail?.value ? event.detail.value : null;
        var selectedDate = new Date(this.inputDate).setHours(0,0,0,0);
        this.showAppointmentType = false;
        this.showSlots = false;
        this.showNoSlots = false;
        if(this.prevTimeSelected){
            this.template.querySelector( `[data-name="${this.timeSelected}"]`).firstChild.classList = 'slds-radio_button__label slds-align_absolute-center';
            this.prevTimeSelected='';
        }
        if(this.reviewFormData.length>0){
            this.reviewFormData = [];
            this.showReviewForm = false;
        }

        if(this.inputDate != null && selectedDate >= new Date(Date.now()).setHours(0,0,0,0) && this.selectedTimeZoneValue && this.coachSelectedId != null) {
            this.showSpinner = true;
            this.fetchTimeSlots(this.inputDate,this.serviceAppointmentId,this.coachSelectedId,this.selectedTimeZoneValue);
            
        }else{
            this.showNoSlots = true;
            this.showSlots = false;
            this.showCoach = false;
            this.showReviewForm = false;
        }
    }
    fetchTimeSlots(inputDate,serviceAppointmentId,coachSelectedId,selectedTimeZoneValue){
        getAllAvailableTimeSlotsForCoach({selectedTime:this.inputDate,userId:userId,serviceAppointmentId:this.serviceAppointmentId,coachId:this.coachSelectedId,timeZone:this.selectedTimeZoneValue}).then((data,error)=>{
                this.showSpinner = true;
                if(data){
                     var coachTimeData = JSON.parse(data);
                     var timeSlotResult;
                     var timeSlotToActualTime;
                     if(coachTimeData != null){
                        timeSlotResult = JSON.parse(coachTimeData.timeSlotData);
                        this.timeSlotToCoachData = JSON.parse(coachTimeData.coachData);
                        timeSlotToActualTime = JSON.parse(coachTimeData.actualVsFormatTimeSlot);
                        this.serviceAppointmentRecord = JSON.parse(coachTimeData.serviceAppointmentRecord);
                        this.userRecord = JSON.parse(coachTimeData.userRecord);
                     }
                    
                    if(timeSlotResult != null && timeSlotResult != ''){

                        this.showSlots = true;
                        if(this.timeSlots){
                            this.timeSlots=[];
                        }
                     }else{
                        this.showNoSlots = true;
                     }
                    if(timeSlotToActualTime && timeSlotResult){
                        timeSlotResult.forEach(timeSlot=>{
                            if (timeSlotToActualTime.hasOwnProperty(timeSlot)) {
                                const appointment = timeSlotToActualTime[timeSlot];
                                    var slot={};
                                    slot.label = timeSlot;
                                    slot.time = appointment.startTime;
                                    slot.value = appointment.startTime + '@' + appointment.endTime;
                                    this.timeSlots.push(slot);
                            }
                        })
                    }
                    this.timeSlots = this.sortDataByTime(this.timeSlots);
                    setTimeout(() => {
                        this.showSpinner = false;
                    }, 500);
                }else{
                    this.showSpinner = false;
                }
            })
       
    }
    sortDataByTime(data) {
        data.sort((a, b) => {
            const timeA = new Date(a.time).getTime();
            const timeB = new Date(b.time).getTime();
            return timeA - timeB;
        });
    
        return data;
    }
    handleTimeSlotSelection(event){
        this.timeSelected = event.currentTarget?.dataset?.name ? event.currentTarget.dataset.name : null;
        this.timeSelectedActualValue = event.currentTarget?.dataset?.value ? event.currentTarget.dataset.value : null;
        this.handleDynamicCss(this.timeSelected);
       this.showAppointmentType = true;
       if(this.timeSelected){
          this.isNextButtonDisabled = false;
       }
       if(this.reviewFormData.length>0){
            this.reviewFormData = [];
            this.showReviewForm = false;
        }
    }
    handleAppointmentType(event){
        var reviewFormTemp = this.reviewFormData;
        this.appointmentType = event.currentTarget?.dataset?.value ?  event.currentTarget.dataset.value  : null;
        if(this.appointmentType){
            if(this.prevAppTypeSelected){
                this.template.querySelector( `[data-value="${this.prevAppTypeSelected}"]`).classList = 'slds-button slds-radio_button appButton';
            }
         
            if(this.appointmentType=='Call Me'){
                this.isButtonDisabled = true;
                this.appointTypePhone = true;
                this.template.querySelector( `[data-value="${this.appointmentType}"]`).classList = 'slds-button slds-radio_button coachAppTimeClass';
            }else{
                this.isButtonDisabled = false;
                this.appointTypePhone = false;
                this.inputPhoneNumber = '';
                this.template.querySelector( `[data-value="${this.appointmentType}"]`).classList = 'slds-button slds-radio_button coachAppTimeClass';
            }
            reviewFormTemp.forEach(apptype=>{
                    if(apptype.label == 'Appointment Type'){
                        this.template.querySelector( `[data-id="${apptype.id}"]`).value = this.appointmentType;
                        apptype.value = this.appointmentType;
                    }
                })
                this.reviewFormData = reviewFormTemp;
            this.prevAppTypeSelected = this.appointmentType;
        }
       
    }

   

    handlePrevious(){
        this.showReviewForm = false;
        this.isButtonDisabled = true;
        this.appointmentType = '';
        this.appointTypePhone = false;
        setTimeout(() => {
            if(this.inputDate &&  this.timeSelected ){
                this.template.querySelector( `[data-name="${this.timeSelected}"]`).firstChild.classList = 'slds-radio_button__label slds-align_absolute-center slotDynamicCss';
                if(this.selectedTimeZoneValue){
                    this.template.querySelector(`lightning-combobox`).value = this.selectedTimeZoneValue;
                }
            }
        }, 200);
       
    }
    handleNext(event){
        if(this.inputDate && this.timeSelected && this.timeSelectedActualValue){
        if(this.reviewFormData.length > 0){
            this.reviewFormData = [];
            this.showReviewForm = false;
        }
      
        if(this.serviceAppointmentRecord){
            var emailData = {};
            emailData.id = 'reviewemail';
            emailData.label = 'Email';
            emailData.value = this.serviceAppointmentRecord?.Email ? this.serviceAppointmentRecord.Email : null;
            this.reviewFormData.push(emailData);
        }else{
            var emailData = {};
            emailData.id = 'reviewemail';
            emailData.label = 'Email';
            emailData.value = this.userRecord?.Email ? this.userRecord.Email : null;
            this.appEmailId =  this.userRecord?.Email ? this.userRecord.Email : null;
            this.reviewFormData.push(emailData);
        }
        if(this.coachSelected){
            var coach={};
            coach.id = 'reviewcoach';
            coach.label = 'Coach';
            coach.value = this.coachSelected;
            this.reviewFormData.push(coach);
        }
        if(this.timeSelected){
            var timeDate={};
            timeDate.id = 'reviewdatetime';
            timeDate.label = 'Date and Time';
            this.appointmentDateTimeText = this.processDate(this.timeSelected,this.inputDate);
            timeDate.value = this.appointmentDateTimeText;
            this.reviewFormData.push(timeDate);
        }
        var appType={};
        appType.id = 'reviewappointment';
        appType.label = 'Appointment Type';
        appType.value = '';
        this.reviewFormData.push(appType);
        if( this.reviewFormData.length > 0){
            this.showReviewForm = true;
        }
    }
    }
    updateServiceAppointment(event){
        this.showSpinner = true;
        var processStartDateTime = this.timeSelectedActualValue.split('@')[0];
        var processEndDateTime = this.timeSelectedActualValue.split('@')[1];
       
        if(this.isCoachBios){
            createServiceAppointments({
                appStartTime:processStartDateTime,
                appEndTime:processEndDateTime,
                appCoachId:this.coachSelectedId,
                appParentAccount:this.userRecord?.Contact?.AccountId ,
                appType:this.appointmentType,
                appPhone:this.inputPhoneNumber,
                appAdditionalInfo:this.additionalInformation ,
                appContactId:this.userRecord?.ContactId,
                appointmentDateTimeText:this.appointmentDateTimeText,
                selectedTimeZoneValue:this.selectedTimeZoneValue,
                appEmailId:this.appEmailId,
                extNumber : this.extNumber
            }).then((data,error)=>{
                if(data){
                    var serviceApp = JSON.parse(data);
                    if(serviceApp.Id){
                        this.serviceAppointmentId = serviceApp.Id;
                        this.showSpinner = false;
                        this.thankyouMessage = 'scheduled';
                        this.showThankyouForm = true;
                    }
                }
            })
        }else{
            rescheduleServiceAppointments({
                serviceAppId:this.serviceAppointmentId,
                startDate:processStartDateTime,
                endDate:processEndDateTime,
                appType:this.appointmentType,
                appPhone:this.inputPhoneNumber,
                appAdditionalInfo:this.additionalInformation,
                appointmentDateTimeText:this.appointmentDateTimeText,
                selectedTimeZoneValue:this.selectedTimeZoneValue,
                extNumber : this.extNumber
               
           }).then((data,error)=>{
               if(data){
                   var serviceApp = JSON.parse(data);
                   if(serviceApp.Id){
                       this.thankyouMessage = 'rescheduled';
                       this.showThankyouForm = true;
                       this.showSpinner = false;
                   }
               }
           })
        }
        
    }
    handleDynamicCss(timeSelected){
        
        if(this.prevTimeSelected){
            this.template.querySelector( `[data-name="${this.prevTimeSelected}"]`).firstChild.classList = 'slds-radio_button__label slds-align_absolute-center';
        }
        const selector = `[data-name="${timeSelected}"]`;
        const element = this.template.querySelector(selector);
        element.firstChild.classList = 'slds-radio_button__label slds-align_absolute-center slotDynamicCss';
        this.prevTimeSelected = timeSelected;
    }
    sortTime(data){
        data.sort((a, b) => {
            const labelA = a.label.toUpperCase();
            const labelB = b.label.toUpperCase();
    
            // Separate AM and PM labels
            const isAM_A = labelA.includes('AM');
            const isAM_B = labelB.includes('AM');
    
            if (isAM_A && !isAM_B) {
                return -1; // AM comes before PM
            } else if (!isAM_A && isAM_B) {
                return 1; // PM comes after AM
            } else {
                // If both are AM or both are PM, sort them alphabetically
                if (labelA < labelB) {
                return -1;
                }
                if (labelA > labelB) {
                return 1;
                }
            return 0;
            }
        });
        return data;
    }

    activeSectionMessage = '';
    activeSections = ['A','B', 'C'];

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }
    handlePhoneNumberChange(event){
        const target = event.target;
        const input = event.target.value.replace(/\D/g, '').substring(0, 10); // First ten digits of input only
        const zip = input.substring(0, 3);
        const middle = input.substring(3, 6);
        const last = input.substring(6, 10);

        if (input.length > 6) { target.value = `${zip}-${middle}-${last}`; }
        else if (input.length > 3) { target.value = `${zip}-${middle}`; }
        this.inputPhoneNumber = event.target.value;
        this.isButtonDisabled = this.inputPhoneNumber.length == 12 ? false : true;
    }
    handleExtChange(event){
        const target = event.target;
        this.extNumber = event.target.value;
    }
    handleAdditionalData(event){
        this.additionalInformation =  event.target.value;
    }
    processDate(startDate,selectedDate){
        var processedTime;
        var processDate;
        var formatDateTime = '';
        if(startDate != null){
            processedTime = startDate.split('-')[0] + startDate.slice('-2');
        }
        if(selectedDate != null){
            processDate = new Date(selectedDate+' 00:00').toDateString();
        }
        if(processDate && processedTime){
            formatDateTime = processDate +' '+processedTime;
        }
        this.tzOptions.forEach(tzOpt => {
            if(tzOpt.value == this.selectedTimeZoneValue){
                formatDateTime = formatDateTime +' ' + tzOpt.label;
            }
        })
       return formatDateTime;
    }
    selectCoach() { 
        this.defaultStyle = 'border: 3px solid rgb(0, 95, 178);cursor: pointer;'
    }
 
    handleClose() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.baseUrl+'/'
            }
        }).then(url => {
            window.open(url, "_self")
        });
        const payload = { recordId: this.serviceAppointmentId };
        publish(this.messageContext, appointmentChannel, payload);
    }
    handleOkay() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.baseUrl+'/'
            }
        }).then(url => {
            window.open(url, "_self")
        });
    }
}
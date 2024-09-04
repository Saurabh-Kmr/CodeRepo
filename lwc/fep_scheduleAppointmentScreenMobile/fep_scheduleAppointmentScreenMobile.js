import { LightningElement,api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getAllAvailableTimeSlots from '@salesforce/apex/Fep_ScheduleAppointmentController.getAllAvailableTimeSlots';
import getAvailableCoachData from '@salesforce/apex/Fep_ScheduleAppointmentController.getAvailableCoachData';
import getReviewScreenData from '@salesforce/apex/Fep_ScheduleAppointmentController.getReviewScreenData';
import createServiceAppointments from '@salesforce/apex/Fep_ScheduleAppointmentController.createServiceAppointments';
import getTimeZoneList from '@salesforce/apex/Fep_ScheduleAppointmentController.getTimeZoneList';
import getSelectedTimeZone from '@salesforce/apex/Fep_ScheduleAppointmentController.getSelectedTimeZone';
import userId from '@salesforce/user/Id';
import formFactorPropertyName from "@salesforce/client/formFactor";
import { NavigationMixin } from 'lightning/navigation';
// import basePath from '@salesforce/community/basePath';
import BASE_URL from '@salesforce/label/c.baseUrl';

import { publish, MessageContext } from 'lightning/messageService';
import appointmentChannel from '@salesforce/messageChannel/FEP_AppointmentBookingChannel__c';



export default class Fep_scheduleAppointmentScreenMobile extends  NavigationMixin(LightningElement) {
    @api options = [];
    baseUrl = BASE_URL;
    //For showing slot screen
    showSlots = false;
    showNoSlots = false;
    coachBiosUrl;
    //For Showing Coach Screen
    showCoach = false;

    //For showing appointment Type
    showAppointmentType = false;
    
    //For showing appointment Type

    //initially selected date
    inputDate;
    
    //initial selected Time - contain label
    timeSelected;

    //Time Selected actual Value
    timeSelectedActualValue;

    //Coach Data from first call
    timeSlotToCoachData;

    //Slected Coach Name
    coachSelected;

    //appointmet Type
    appointmentType;
    //show enter phone field
    appointTypePhone = false;
    //make button disable
    isButtonDisabled = true;

    //Phone Number Value
    inputPhoneNumber;
    //additional inforamtion
    additionalInformation;

    //PreviousSelectedSlot
    prevTimeSelected;
    prevCoachSelected;
    prevAppTypeSelected;
    //show Thank You form
    showThankyouForm = false;

    //service App contact Id
    serviceAppContactId;
    isNextButtonDisabled = true;
    appointmentDateTimeText;

    showDate = true;
    timeSlots = [];
   

    coachDetail=[];
    showReviewForm = false;
   
   
   
    allCoachData;

    showStartDate;
    showEndDate;
    showWorktype;
    showEmailId;
    reviewFormData=[];

    //Selected Coach Id
    serviceAppCoachId;

    serviceAppParentAccId;

    //Select Coach Style
    defaultStyle='cursor: pointer;border: 3px solid rgb(0, 95, 178);';

    showSpinner = false;

    serviceAppointmentId;

    showTZOnLoad = true;
    tzOptions = [];
    selectedTimeZoneValue;
    selectedTimeZone;
    extNumber;
    appEmailId;
    selectedValue;
    timeSlotDuration;
    @wire(MessageContext)
    messageContext;





    connectedCallback(){
        this.handleLoad();
        this.handleSelectedTime();
        this.coachBiosUrl = this.baseUrl+`/coach-bios`
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

      handleTZChange(event){
        var selectedOptionLabel;
        this.showSlots = false;
        this.showCoach = false;
        this.prevTimeSelected = '';
        this.prevCoachSelected = '';
       
        this.isNextButtonDisabled = true;
        this.selectedTimeZoneValue = event.detail.value;
        if(this.selectedTimeZoneValue != null){
            selectedOptionLabel = this.tzOptions.find(opt => opt.value === this.selectedTimeZoneValue);
            if(selectedOptionLabel){
                this.selectedTimeZone = selectedOptionLabel.label;
            }
            //this.showSpinner = true;
            if(this.inputDate != null){
            this.fetchTimeSlots(this.inputDate,this.selectedTimeZoneValue);
            }
        }
       
       
       
      }


    handleDateChange(event){
        this.inputDate = event.detail?.value ? event.detail.value : null;
        var selectedDate = new Date(this.inputDate).setHours(0,0,0,0);
        this.showCoach = false;
        this.showSlots = false;
        this.showNoSlots = false;
        this.isNextButtonDisabled = true;
        this.coachSelected ='';
      
        this.serviceAppCoachId = '';
        if(this.prevTimeSelected && this.timeSelected){
            this.template.querySelector( `[data-name="${this.timeSelected}"]`).firstChild.classList = 'slds-radio_button__label slds-align_absolute-center';
            this.prevTimeSelected='';
            this.timeSelected = '';
        }
        if(this.prevCoachSelected){
            this.prevCoachSelected = '';
        }
      
        if(this.inputDate != null && selectedDate >= new Date(Date.now()).setHours(0,0,0,0) && this.selectedTimeZoneValue) {
            this.showSpinner = true;
            this.fetchTimeSlots(this.inputDate,this.selectedTimeZoneValue);
           
        }else{
            this.showNoSlots = true;
            this.showSlots = false;
            this.showCoach = false;
        }

    }

    fetchTimeSlots(inputDate,selectedTimeZoneValue){
        getAllAvailableTimeSlots({selectedTime:inputDate,userId:userId,timeZone:selectedTimeZoneValue}).then((data,error)=>{
            if(data){
               
                 var coachTimeData = JSON.parse(data);
                 var timeSlotResult;
                 var timeSlotToActualTime;
                 if(coachTimeData != null){
                    timeSlotResult = JSON.parse(coachTimeData.timeSlotData);
                    this.timeSlotToCoachData = JSON.parse(coachTimeData.coachData);
                    timeSlotToActualTime = JSON.parse(coachTimeData.actualVsFormatTimeSlot);
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
    handleDynamicCss(timeSelected){
        
        if(this.prevTimeSelected){
            this.template.querySelector( `[data-name="${this.prevTimeSelected}"]`).firstChild.classList = 'slds-radio_button__label slds-align_absolute-center';
            
        }
        const selector = `[data-name="${timeSelected}"]`;
        // Query the element by its data-id attribute
        const element = this.template.querySelector(selector);
        element.firstChild.classList = 'slds-radio_button__label slds-align_absolute-center slotDynamicCss';
        this.prevTimeSelected = timeSelected;
    }
    
    getCoachesForSelectedTime(event){
        var selectedSlotCoaches;
        this.showCoach = false;
       if(this.timeSelected){
            this.serviceAppCoachId ='';
            this.coachSelected = '';
       }
       this.isNextButtonDisabled = true;
        this.timeSelected = event.currentTarget?.dataset?.name ? event.currentTarget.dataset.name : null;
        this.timeSelectedActualValue = event.currentTarget?.dataset?.value ? event.currentTarget.dataset.value : null;
        this.handleDynamicCss(this.timeSelected);
        if(this.prevCoachSelected){
            this.template.querySelector( `[data-id="${this.prevCoachSelected}"]`).classList = 'slds-box slds-m-around_small';
            this.prevCoachSelected = '';
        }
        if(this.timeSelected != null && this.timeSlotToCoachData != null && this.timeSelectedActualValue != null){
            if(this.reviewFormData.length>0){
                this.reviewFormData = [];
                this.showReviewForm = false;
            }
            selectedSlotCoaches = this.timeSlotToCoachData[this.timeSelected] != null ? this.timeSlotToCoachData[this.timeSelected] : null;
            
            if(selectedSlotCoaches){
                this.showSpinner = true;
                getAvailableCoachData({ coachIds : selectedSlotCoaches }).then((data,error)=>{
                    if(data){
                       
                        this.allCoachData =  JSON.parse(data);
                        if(this.coachDetail.length >0){
                            this.coachDetail=[];
                        }
                        if(this.allCoachData){
                            this.allCoachData.forEach(cData=>{
                                var slot={};
                                slot.Name = cData.Name;
                                slot.Id = cData.Id;
                                slot.photoUrl = cData?.RelatedRecord?.MediumPhotoUrl;
                                this.coachDetail.push(slot);
                            })
                         }
                         setTimeout(() => {
                            this.showCoach = true;
                            this.showSpinner = false;
                        }, 500); 
                    }else{
                        this.showCoach = false;
                        this.showSpinner = false;
                    }
                })
            }
          
        }
    }
    
    dynamicCssForCard(coachId){

        if(this.prevCoachSelected){
            this.template.querySelector( `[data-id="${this.prevCoachSelected}"]`).classList = 'slds-box slds-m-around_small';

        }
        const selector = `[data-id="${coachId}"]`;
        const element = this.template.querySelector(selector);
        element.classList = 'slds-box slds-m-around_small coachCardClass';
            this.prevCoachSelected = coachId;
    }
     
    
    
    handleCardClick(event){
        this.coachSelected = event.currentTarget?.dataset?.value ?  event.currentTarget.dataset.value : null;
        this.serviceAppCoachId =  event.currentTarget?.dataset?.id ?  event.currentTarget.dataset.id : null;
        this.dynamicCssForCard(this.serviceAppCoachId);

        if(this.inputDate && this.coachSelected && this.timeSelected && this.serviceAppCoachId){
            this.isNextButtonDisabled = false;
            
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
                this.template.querySelector( `[data-value="${this.appointmentType}"]`).classList = 'slds-button slds-radio_button appButtonSelected';
            }else{
                this.isButtonDisabled = false;
                this.appointTypePhone = false;
                this.inputPhoneNumber = '';
                this.template.querySelector( `[data-value="${this.appointmentType}"]`).classList = 'slds-button slds-radio_button appButtonSelected';
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

  

    createServiceAppointment(){
       
        this.showSpinner = true;
        var processStartDateTime = this.timeSelectedActualValue.split('@')[0];
        var processEndDateTime = this.timeSelectedActualValue.split('@')[1];
       
        
        createServiceAppointments({appStartTime:processStartDateTime,
            appEndTime:processEndDateTime,
            appCoachId:this.serviceAppCoachId,
            appParentAccount:this.serviceAppParentAccId,
            appType:this.appointmentType,
            appPhone:this.inputPhoneNumber,
            appAdditionalInfo:this.additionalInformation ,
            appContactId:this.serviceAppContactId,
            appointmentDateTimeText:this.appointmentDateTimeText,
            selectedTimeZoneValue:this.selectedTimeZoneValue,
            appEmailId :  this.appEmailId,
            extNumber : this.extNumber
        }).then((data,error)=>{
            if(data){
                var serviceApp = JSON.parse(data);
                if(serviceApp.Id){
                    this.serviceAppointmentId = serviceApp.Id;
                    this.showSpinner = false;
                    this.showThankyouForm = true;
                }
            }
        })
    }

    handleNext(event){
        if(this.inputDate && this.serviceAppCoachId && this.coachSelected && this.selectedTimeZoneValue){
            getReviewScreenData({selectedCoachId:this.serviceAppCoachId,loggedInUserId:userId}).then((data,error)=>{
                if(data){
                    var reviewData = JSON.parse(data);
                    this.serviceAppParentAccId = reviewData?.parentAccountId ? reviewData.parentAccountId : null;
                    this.serviceAppContactId =  reviewData?.contactId ? reviewData.contactId : null;
                    if(this.reviewFormData.length > 0){
                        this.reviewFormData = [];
                        this.showReviewForm = false;
                    }
                  
                    if(reviewData){
                        var emailData = {};
                        emailData.id = 'reviewemail';
                        emailData.label = 'Email';
                        emailData.value = reviewData.emailId;
                        this.appEmailId = reviewData.emailId;
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
                    appType.value = this.appointmentType;
                    this.reviewFormData.push(appType);
                    if( this.reviewFormData.length > 0){
                        this.showReviewForm = true;
                    }
                }
            })
            
        }
       
    }
    handlePrevious(){
        this.showReviewForm = false;
        this.isButtonDisabled = true;
        this.appointmentType ='';
        this.appointTypePhone = false;
        setTimeout(() => {
            if(this.inputDate &&  this.timeSelected && this.serviceAppCoachId){
                this.template.querySelector( `[data-id="${this.serviceAppCoachId}"]`).classList = 'slds-box slds-m-around_small coachCardClass';
                this.template.querySelector( `[data-name="${this.timeSelected}"]`).firstChild.classList = 'slds-radio_button__label slds-align_absolute-center slotDynamicCss';
                if(this.selectedTimeZoneValue){
                    this.template.querySelector(`lightning-combobox`).value = this.selectedTimeZoneValue;
                }
            }
        }, 200);
       
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

    formatDateTime(dateString,timeString){
        var formatDateTime;
        // Parse the time string
        const [time, period] = timeString.split(' ');

        // Parse hours and minutes
        const [hours, minutes] = time.split(':').map(Number);

        // Convert hours to 24-hour format
        let hours24 = hours % 12;
        hours24 += period.toLowerCase() === 'pm' ? 12 : 0;

        // Format the hours and minutes to ensure leading zeros
        const formattedHours = String(hours24).padStart(2, '0');
        const formattedMinutes = String(minutes).padStart(2, '0');

        // Construct the time string in 24-hour format
        const time24 = `${formattedHours}:${formattedMinutes}`;

        // Output time in 24-hour format
        formatDateTime = dateString + ' '+time24+':00+0000Z';
       return formatDateTime;
    }
   
     sortDataByTime(data) {
        data.sort((a, b) => {
            const timeA = new Date(a.time).getTime();
            const timeB = new Date(b.time).getTime();
            return timeA - timeB;
        });
    
        return data;
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

    handleClose(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.baseUrl+'/'
            }
        }).then(url => {
            window.open(url, "_self")
        });
       
        //publish event on LMS
        const payload = { recordId: this.serviceAppointmentId };
        publish(this.messageContext, appointmentChannel, payload);
    }








}
import { LightningElement,track,wire,api } from 'lwc';
import getCoachAvailableTime from '@salesforce/apex/FEP_CoachBios.getCoachAvailableTime';
import fep_reScheduleAppointmentScreen from 'c/fep_reScheduleAppointmentScreen';
import formFactorPropertyName from "@salesforce/client/formFactor";
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import BASE_URL from '@salesforce/label/c.baseUrl';

export default class Fep_coachBiosComponent extends  NavigationMixin(LightningElement) {

    coach;
    baseUrl = BASE_URL;
    showTag
    availableDate;
    @track coachAvailablity = [];

    @api 
    get coachDetails(){

        return this.coach;
    }

    set coachDetails(value){

        this.coach= value
    }


    @wire(getCoachAvailableTime,{resourceId:'$coach.serviceResourceId',territoryId:'$coach.serviceTerritoryId'})
    getNextAvailablity(result) {
  
        console.log(result)
        if(result.data){

            console.log(result.data);
            if(result.data){
                this.showTag = result.data!=='No available appointments'?true:false;
                this.availableDate =result.data;
            }
           // this.coachAvailablity = JSON.parse(result.data);
           // if(this.coachAvailablity.length > 0){

              //  const formattedDate = new Date(this.coachAvailablity[0].startTime);
              //  this.availableDate = formattedDate.toLocaleDateString('en-US', {day:"numeric", year:"numeric", month:"long"})+ ' '+ formattedDate.toLocaleTimeString("en-US", { hour12: true,hour: "2-digit", minute: "2-digit" });
                
           // }
    
        }
       
    }

    async openSchedularForBios(event){
            if(formFactorPropertyName == 'Small'){
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__webPage',
                    attributes: {
                        url: this.baseUrl+`/reschedule-appointment?coachId=${this.coach.serviceResourceId}&isCoachBios=${true}&coachName=${this.coach?.coach_name}`
                        
                    }
                }).then(url => {
                    window.open(url, "_self")
                });
            }else{
                console.log('coach bios'+JSON.stringify(this.coach))
        const result = await fep_reScheduleAppointmentScreen.open({
            size: 'medium',
            description: 'Accessible description of modal\'s purpose',
            content: {

                coachId:this.coach.serviceResourceId,
                appointmentId:null,
                coachName:this.coach?.coach_name,
                isCoachBios:true
            },
        });
    }
    }

}
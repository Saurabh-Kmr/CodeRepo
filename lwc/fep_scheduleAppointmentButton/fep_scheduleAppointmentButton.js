import { LightningElement } from 'lwc';
import fep_scheduleAppointmentScreen from 'c/fep_scheduleAppointmentScreen';
import formFactorPropertyName from "@salesforce/client/formFactor";
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import BASE_URL from '@salesforce/label/c.baseUrl';


export default class Fep_scheduleAppointmentButton extends NavigationMixin(LightningElement) {
    baseUrl = BASE_URL;

    async handleClick() {
        console.log('formFactorPropertyName'+formFactorPropertyName);
        if(formFactorPropertyName == 'Small'){
            // if(window.matchMedia("(max-width: 800px)").matches){
            console.log('basePath'+basePath)
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: this.baseUrl+'/schedule-appointment'
                }
            }).then(url => {
                window.open(url, "_self")
            });
        }else{
            const result = await fep_scheduleAppointmentScreen.open({
                size: 'medium',
                description: 'Accessible description of modal\'s purpose',
                content: 'Passed into content api',
                
            }).then((result) => {
                console.log(result);
            });
        }
        
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);
    }
}
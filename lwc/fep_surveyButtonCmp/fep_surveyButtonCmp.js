import { LightningElement, wire } from 'lwc';
import Id from "@salesforce/user/Id";
import getSurveyDetails from '@salesforce/apex/FEP_LogoutButtonController.getUserDetails';

export default class Fep_surveyButtonCmp extends LightningElement {


    userId= Id;
    surveyUrl;

    @wire(getSurveyDetails, {userId:'$userId'})
    getWebinarList(result) {
        if(result.data){
            const userDetails = JSON.parse(result.data);
            this.surveyUrl = userDetails.surveyUrl; 
        }
    }

    redirectToSurveyLink(event){
        window.open(this.surveyUrl, "_blank")
    }




}
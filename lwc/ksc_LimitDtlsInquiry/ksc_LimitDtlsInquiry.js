/* Component Name : Ksc_LimitDtlsInquiry
** Description:This is the  component for Displaying Limit details
** Author : Chaynnitt Agarwal
** Created Date : Jan 14, 2023
** Last Modified Data : Jan 19, 2023
** Parent Story Number : NA
*/
import { LightningElement,api,track } from 'lwc';

import initiateCallout from '@salesforce/apex/ksc_IntegrationCalloutHandler.initiateCallout';
import errorLabel from '@salesforce/label/c.ksc_ErrorMessage';

export default class Ksc_LimitDtlsInquiry extends LightningElement {
    
    label ={
        errorText :errorLabel
    };
    @track showSpinner;
    @track showError;
    @track errorMessage;
    @track data = [];
    @track limitId;

    @api 
    get limitInqId(){
        return this.limitId;
    }

    /****************************************************
     * @Description - Works Limit Id value passed from the Parent component.     
     * @param  -    none
    *****************************************************/
    set limitInqId(detail){
        this.limitId = detail;
        this.makeAPICall();
    }

    /****************************************************
     * @Description - Works on onload of LWC component.     
     * @param  -    none
    *****************************************************/
    connectedCallback(){
        this.showSpinner = true;
        this.showError = false;
    }

    /****************************************************
     * @Description - Method to get the data from Apex.     
    *****************************************************/
    makeAPICall(){
        let lwcReqObj = {"limitId" : this.limitId};
        this.showSpinner = true;
        initiateCallout({
            strSettingName: 'LimitDtlsInquiry_API',
            strLWCCardDetails: JSON.stringify(lwcReqObj)
        })
        .then(result => {
            if(result != null && result != ''){
                if(result.strResponseStatusCode == '200'){
                    this.data = JSON.parse(result.strResponseBody) ;
                    this.showSpinner = false;
                }else{
                    this.showError = true;
                    this.showSpinner = false;
                    let jsonParse = JSON.parse(result.strResponseRawJSON);
                    this.errorMessage = '[Error code : '+jsonParse.code +']'+
                ' [' +jsonParse.error.errorMessage +' : '+ jsonParse.error.errorDetails+'].For further assistance please contact system admin.' ;
                }
            }else{
                this.showError = true;
                this.showSpinner = false;
                this.errorMessage =this.label.errorText;
            }
            
        })
        .catch(error => { 
            this.addErrorLog(JSON.stringify(error));
            this.showSpinner = false;
            this.showError = true;
            this.errorMessage = this.label.errorText;
            this.addErrorLog(JSON.stringify(error.stack));
            this.addErrorLog(JSON.stringify(error.errorMessage));
        });
    }

    /********************************************************************
     * @Description - Method to request data from Apex on Retry action
    *********************************************************************/
    handleRetry(){
        this.makeAPICall();
    }

    /********************************************************************
     * @Description - Method to add nebula logger on error
    *********************************************************************/
    addErrorLog(error_message) {
        console.log('Error ' + error_message);
    }

}
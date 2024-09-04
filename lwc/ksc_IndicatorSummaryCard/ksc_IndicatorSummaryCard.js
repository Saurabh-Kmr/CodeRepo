/*********************************************************
*Component Name        :  Ksc_IndicatorSummaryCard
*Author       :  Shreya Mathur
*Description  :  LWC Conponent that opens the LWC Component
*********************************************************/

import { LightningElement,api,track, wire } from 'lwc';
import initiateCallout from '@salesforce/apex/ksc_IntegrationCalloutHandler.initiateCallout';
import { publish,subscribe,unsubscribe,createMessageContext,releaseMessageContext,
    APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import SAMPLEMC from "@salesforce/messageChannel/ksc_C360MessageChannel__c";

export default class Ksc_IndicatorSummaryCard extends LightningElement {
    @api propertyValue;
    @track receivedMessage = '';
    @track myMessage = '';
    subscription = null;
    displayResult =[];
    displayList =[];
    displayCardNames='';
    context = createMessageContext();

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.subscribeMC();
    }

    /** Description - Method to handle the Subcription of LMS. */
    subscribeMC() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.context, SAMPLEMC, (message) => {
            this.displayMessage(message);
        },{scope: APPLICATION_SCOPE });
     }

    /** Description - Method to handle the Subcription of LMS. */
    displayMessage(message) {
        this.receivedMessage = message ? JSON.stringify(message, null, '\t') : 'no message payload';
        if(message.boolLoadLWC == "true"){
            this.handleCardCallout(message) ;
          //  this.receivedMessage ="";
        }
    }

    /** Description - Method to handle the child card loadon side bar */
    handleCardCallout(message) {
       this.receivedMessage = message.strMessage;
       if(message.strMessage == "NACH Declaration"){
            initiateCallout({
                strSettingName: 'Indicator_API'
            })
            .then(result => {
            var jsonParse='';
            var strBody='';
            this.jsonParse = JSON.parse(result);
            this.strBody =this.jsonParse.strResponseBody;
            this.displayResult= JSON.parse(this.strBody);
            this.displayList =[];
            
            this.displayResult.forEach((element) => {
                this.displayList.push(element.fieldAPI);
            });

            this.displayCardNames= JSON.stringify(this.displayList);
            this.receivedMessage = this.displayCardNames;
            })
            .catch(error => { 
                console('Error');
                this.receivedMessage = 'Error!!';
            });
       }
       //message ? JSON.stringify(message, null, '\t') : 'no message payload';
    }

}
import { LightningElement,api,wire } from 'lwc';
import getFieldWrapperDetails from '@salesforce/apex/ksc_AddressHistoryParserClass.generateFieldConfigWrapper';
import SAMPLEMC from '@salesforce/messageChannel/ksc_C360MessageChannel__c';
import { NavigationMixin } from 'lightning/navigation';
import {publish,
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,createMessageContext,
} from 'lightning/messageService';


export default class Ksc_addressHistory extends NavigationMixin(LightningElement) {
    @wire(MessageContext)
    messageContext;
    context = createMessageContext();
    boolShowModal = false;
    strModalData='';
    objModalData ={};


    @api cardName;
    @api strIconName;
    @api isBold;
    @api urlValue;
    lstDisplay=[];
    boolShowModal = false;

    /**
     * Description- Method that renders on onload of the LWC 
     * */
    connectedCallback() {
        this.performApexCall();
    }

    /**
     * Description- Method to perfrom Apex Callouts 
     * */
    performApexCall(){
        getFieldWrapperDetails()
        .then(result => {
           this.jsonParse = JSON.stringify(result);
           //console.log('this.jsonParse '+this.jsonParse);
           var recs1 = [];
           var recs2 = [];
           for ( let rec of JSON.parse(this.jsonParse ) ) {
            if(rec.strGroupName == 'Address History column'){
                recs1.push( rec );
            }/*else if(rec.strGroupName == 'Nominee details Columns'){
                recs2.push( rec );
            }*/
           }
           this.lstDisplay = recs1; 
           //this.nomineeDisplay = recs2;
        })
        .catch(error => {
            console.log('Error Occured '+JSON.stringify(error));
        });
    }

    
    handleClick() {
    this.boolShowModal = true;
}

handleNavigate(event) {
    event.preventDefault();
    var strCardName = event.target.value;
    this.boolShowModal = !this.boolShowModal;//!event.target.value;
    this.objModalData = {strModaltitle:'Sample Header', 
                        strbuttonName:'Cancel Button',
                        strModalContent:'Hello World 2',
                        objModalContent:[],
                        strMargintop:'10%',
                        strMarginleft:'70%',
                        strMarginright:'20%',
                        strposition:'fixed',
                        strModalheight:'80%'
                        };
     this.strModalData = JSON.stringify(this.objModalData);
        const message = {
            strMessage: strCardName,
            boolLoadLWC: "true"
        };
       publish(this.context, SAMPLEMC, message);

      
    }
}
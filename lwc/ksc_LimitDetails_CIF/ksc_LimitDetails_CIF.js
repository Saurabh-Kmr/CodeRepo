/* Component Name : Ksc_LimitDetails_CIF
** Description:This is the  component for displaying limit details based on CIF
** Author : Saurabh Kumar
** Created Date : Jan 12, 2023
** Last Modified By : 
** Last Modified Data : 
** Parent Story Number : 
*/
import { LightningElement,api,track } from 'lwc';
import initiateCallout from '@salesforce/apex/ksc_IntegrationCalloutHandler.initiateCallout';
import getCrnFromAssest from '@salesforce/apex/ksc_LimitDetailsParserClass.getCRNFromAsset';
import errorLabel from '@salesforce/label/c.ksc_ErrorMessage';

export default class Ksc_LimitDetails_CIF extends LightningElement {
    
    label ={
        errorText :errorLabel
    };

    selectedRow = [];
    @track columns = [];
    showSpinner = true;
    assetObj;
    error;
    @track data = [];
    crn;
    assetID;
    limitID;
    islimitSelected = false;
    invokeHeaderApi = false;
    

    @api get assetDetailJson(){
        return this.assetObj;
    }

    set assetDetailJson(value){
        this.islimitSelected = false;
        if(this.template.querySelector('lightning-datatable') != null){this.template.querySelector('lightning-datatable').selectedRows=[];}
        this.assetObj = value;
        let parsedJsObj = JSON.parse(this.assetObj);
        this.assetID = parsedJsObj.Id;
        this.fetchAssetData();

    }


    fetchAssetData(){
         getCrnFromAssest({assetID: this.assetID}).then(result=>{
             this.crn= result;
             this.makeAPICall();
         }).catch(error=>{
             this.showSpinner = false;
             this.error = this.label.errorText;
         });
          
    }

    makeAPICall(){
         initiateCallout({strSettingName: 'LimitDetails_API', 
                                                 strRecordId: this.crn, 
                                                 strLWCCardDetails: ''
                                                }).then(result=>{
                this.invokeHeaderApi = true; //Megha : added to invoke another api
                if(result !=null && result !=''){
                if (result.strResponseStatusCode == '200') {
                    let strBody = result.strResponseBody;
                    let displayResult = JSON.parse(strBody);
                    this.columns = displayResult.columns;
                    this.data = JSON.parse(displayResult.rowData);
                    this.showSpinner = false;
                    this.error = null;
                } else {
                    this.data = null;
                    this.showSpinner = false;
                    let jsonParse = JSON.parse(result.strResponseRawJSON);
                    this.error = '[Error code : '+jsonParse.code +']'+
                ' [' +jsonParse.error.errorMessage +' : '+ jsonParse.error.errorDetails+'].For further assistance please contact system admin.' ;
                }
            
            }
            else{
                this.data = null;
                this.showSpinner = false; 
                this.error = this.label.errorText;
            }
            }).catch(error=>{
            this.data = null;
            this.showSpinner = false;
            this.error = this.label.errorText;
            this.addErrorLog(error);
        });
    }


    async handleRetry() {
        try{
            await this.makeAPICall();
        }
        catch(error){
            this.addErrorLog(error);
        }
    }

    handleRowSelection(event){
        try{
            let selectedRows = event.detail.selectedRows;
            this.limitID = selectedRows[0].limitId;
            this.islimitSelected = true;
        }
        catch(error){
            this.addErrorLog(error);
        }
    }

    /********************************************************************
     * @Description - Method to add nebula logger on error
    *********************************************************************/
    addErrorLog(error_message) {
        console.log('Error ' + error_message);
     }

}
/* Component Name : Ksc_IndicatorComponent
** Description:This is the  component for Displaying Indicators card
** Author : Shreya Mathur
** Created Date : Nov 23, 2022
** Last Modified Data : Nov 23, 2033
** Parent Story Number : NA
*/
import { LightningElement,api,track } from 'lwc';
import getIndicatorData from '@salesforce/apex/ksc_IndicatorCardController.getIndicatorData';

export default class Ksc_IndicatorComponent extends LightningElement {
    @api recordId;
    @api objectApiName;
    displayResult = [];
    lstInputEnum = [];
    lstInputEnum1 = [];
    strSectionName =['Indicators'];
    boolShowSpinner = true;
    boolShowError = false;
    strErrorMsg = 'An unexpected error occured. Please contact your System Administrator.';

    /****************************************************
     * @Description - Works on onload of LWC component.     
     * @param  -    none
    *****************************************************/

    connectedCallback() {
        this.promiseMethod();
    }

    /****************************************************
     * @Description - Async Method to get the data from Apex via promise.     
     * @param  -    Resolve : Standard Resolve method of Promise
    *****************************************************/

    async promiseMethod(){
        await new Promise((resolve, reject)=>{
            this.fetchData(resolve,reject);
        }).then((result)=> { 
            if(result === 'resolve'){
                this.boolShowSpinner = false;
            }
            else if(result =='Reject'){
                this.boolShowSpinner = false;
                this.boolShowError = true;
            }
          })
          .catch((error) => { 
            this.boolShowSpinner = false;
            this.boolShowError = true;
          });
         // this.boolShowAsyncEg = true; 
    }

    /****************************************************
     * @Description - Promise Method to get the data from Apex.     
     * @param  -    Resolve : Standard Resolve method of Promise,
     * @param  -    Reject : Standard Resolve method of Promise
    *****************************************************/

    fetchData(resolve, reject) {
        getIndicatorData({
            strRecordId: this.recordId,
        })
        .then(result => {
          
          if(result && result != undefined && !result[0].strErrorMessage){
          this.displayResult= result;
            this.displayResult.forEach((element) => {
                this.lstInputEnum1.push(element);
                if(element.isError == true){
                    this.strErrorMsg = element.strErrorMessage;
                    reject('Reject');
                }
            });
            this.lstInputEnum = this.lstInputEnum1;
            resolve('resolve');
           }  
           else{
            reject('Reject');
           }
        })
        .catch(error => { 
            reject('Reject');
        });
    }

}
import { LightningElement,api,track,wire} from 'lwc';
import getWebinarInfo from '@salesforce/apex/FEP_WebinarInfo.getWebinarInfo';
import Id from "@salesforce/user/Id";

export default class Fep_webinarsList extends LightningElement {


    userId = Id;
    recordsFound=false
    @track listOfWebinars= [];


    @wire(getWebinarInfo,{userId:'$userId'})
    getWebinarList(result) {
  
        if(result.data){

            console.log(result.data);

            var resultData = JSON.parse(result.data);
            resultData.forEach((currentElement) => {

                const customDate = new Date(currentElement.StartDate);
                currentElement.StartDate = customDate.toLocaleDateString("en-US");

                console.log( currentElement.StartDate );

                this.listOfWebinars.push(currentElement);
            });

            // var today  = new Date();

            // console.log(today.toLocaleDateString("en-US"));

            //this.listOfWebinars = JSON.parse(result.data);

            this.recordsFound = (this.listOfWebinars.length) > 0 ? true : false;
           
        }
       
    }


}
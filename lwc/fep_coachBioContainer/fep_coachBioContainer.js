import { LightningElement,track,wire} from 'lwc';
import getCoachList from '@salesforce/apex/FEP_CoachBios.getCoachList';
export default class Fep_coachBioContainer extends LightningElement {


    @track listOfCoaches = [];

    imageUrl;
    coachName='';

    @wire(getCoachList)
    coachList(result) {


        console.log(result);
        if(result.data){

            this.listOfCoaches = JSON.parse(result.data);

            // this.imageUrl = this.listOfCoaches[0].MediumPhotoUrl;
            // this.coachName = this.listOfCoaches[0].ServiceResources.records[0].Name;

        }
    }

}